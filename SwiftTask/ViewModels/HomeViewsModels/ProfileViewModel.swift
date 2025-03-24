//
//  ProfileViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: ProfileModel?
    @Published var profileImageData: Data? = nil
    @Published var isLoading: Bool = false
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                loadImage(from: imageSelection)
            }
        }
    }
    @Published var isShowingDeleteAccountAlert = false
    @Published var isShowingDeleteAccountConfirmation = false
    @Published var deleteAccountError: String?
   
    private let context = PersistenceController.shared.viewContext
    private let offlineSyncManager = OfflineSyncManager.shared
    
    // TaskCounts'u public yapalım ve ayrı bir dosyaya taşıyalım ya da aynı dosyada public olarak tanımlayalım
    struct TaskCounts {
        let done: Int
        let left: Int
    }
    
    // Public computed properties ekleyelim
    @Published private(set) var taskCounts = TaskCounts(done: 0, left: 0)
    
    // Public access için computed properties
    var completedTasks: Int {
        taskCounts.done
    }
    
    var remainingTasks: Int {
        taskCounts.left
    }
    
    init() {
        loadLocalData()
        syncWithFirebase()
        
        // Notification observer'ı ekleyelim
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskCountsUpdate),
            name: .tasksUpdated,
            object: nil
        )
    }
    
    private func loadLocalData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Load profile from CoreData
        if let cachedProfile = CoreDataManager.shared.fetchUserProfile(userId: userID) {
            self.user = cachedProfile
        }
        
        // Load profile image from CoreData
        let imageData = CoreDataManager.shared.fetchProfileImage(userId: userID)
        self.profileImageData = imageData
    }
    
    private func syncWithFirebase() {
        guard offlineSyncManager.isOnline else { return }
        
        Task { @MainActor in
            await fetchUserData()
        }
    }
    
    // Task counts güncellemesi için yeni metod
    @objc private func handleTaskCountsUpdate(_ notification: Notification) {
        Task { @MainActor in
            if let taskDone = notification.userInfo?["taskDone"] as? Int,
               let taskLeft = notification.userInfo?["taskLeft"] as? Int {
                await updateTaskCounts(done: taskDone, left: taskLeft)
            }
        }
    }
    
    private func updateTaskCounts(done: Int, left: Int) async {
        await MainActor.run {
            taskCounts = TaskCounts(done: done, left: left)
            
            if var updatedUser = user {
                updatedUser.taskDone = done
                updatedUser.taskLeft = left
                user = updatedUser
            }
        }
    }
    
    // Profile güncelleme işlemi için güvenli metod
    func updateProfile(with profile: ProfileModel) {
        Task { @MainActor in
            self.user = profile
            self.taskCounts = TaskCounts(done: profile.taskDone, left: profile.taskLeft)
        }
    }
    
    // Profil resmi güncelleme için güvenli metod
    func updateProfileImage(_ image: UIImage) {
        Task { @MainActor in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            CoreDataManager.shared.saveProfileImage(userId: Auth.auth().currentUser?.uid ?? "", imageData: imageData)
            self.profileImageData = imageData
            NotificationCenter.default.post(name: .profileUpdated, object: nil)
        }
    }
    
    // Image loading için güvenli metod
    private func loadImage(from item: PhotosPickerItem) {
        Task { @MainActor in
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                
                let maxDimension: CGFloat = 1024.0
                let targetSize = CGSize(width: maxDimension, height: maxDimension)
                
                guard let resizedImage = resizeImage(uiImage, to: targetSize),
                      let imageData = resizedImage.jpegData(compressionQuality: 0.8) else { return }
                
                let userId = Auth.auth().currentUser?.uid ?? ""
                CoreDataManager.shared.saveProfileImage(userId: userId, imageData: imageData)
                self.profileImageData = imageData
                NotificationCenter.default.post(name: .profileUpdated, object: nil)
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    private func fetchUserData() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userService = UserService.shared
        
        do {
            let profile = try await withCheckedThrowingContinuation { continuation in
                userService.fetchUserProfile(userID: userID) { profile in
                    if let profile = profile {
                        continuation.resume(returning: profile)
                    } else {
                        continuation.resume(throwing: NSError(domain: "", code: -1))
                    }
                }
            }
            
            // Profile'ı güvenli bir şekilde güncelle
            await MainActor.run {
                self.user = profile
                self.taskCounts = TaskCounts(done: profile.taskDone, left: profile.taskLeft)
            }
            
            // CoreData'ya kaydet
            CoreDataManager.shared.saveUserProfile(userId: userID, profile: profile)
            
        } catch {
            print("Error fetching user data: \(error)")
        }
    }
    
    func saveUserProfile(name: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let updatedProfile = ProfileModel(
            userName: name,
            taskLeft: user?.taskLeft ?? 0,
            taskDone: user?.taskDone ?? 0,
            email: user?.email ?? "",
            timestamp: Date()
        )
        
        CoreDataManager.shared.saveUserProfile(userId: userID, profile: updatedProfile)
        self.user = updatedProfile
        
        if offlineSyncManager.isOnline {
            Task { @MainActor in
                await withCheckedContinuation { continuation in
                    UserService.shared.saveUserProfile(userID: userID, profile: updatedProfile) { [weak self] error in
                        if let error = error {
                            print("Firebase güncelleme hatası: \(error.localizedDescription)")
                            self?.offlineSyncManager.addToQueue(data: ["name": name])
                        }
                        continuation.resume()
                    }
                }
            }
        } else {
            offlineSyncManager.addToQueue(data: ["name": name])
        }
    }
    
    func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func removeProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        CoreDataManager.shared.deleteProfileImage(userId: userID)
        self.profileImageData = nil
        NotificationCenter.default.post(name: .profileUpdated, object: nil)
    }
    
    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        CoreDataManager.shared.clearUserData()
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "User not found.")
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        Task { @MainActor in
            await withCheckedContinuation { continuation in
                user.reauthenticate(with: credential) { _, error in
                    if error != nil {
                        completion(false, "Current password is incorrect.")
                        continuation.resume()
                        return
                    }

                    user.updatePassword(to: newPassword) { error in
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else {
                            completion(true, nil)
                        }
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    func deleteAccount(password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "User not found.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        Task { @MainActor in
            await withCheckedContinuation { continuation in
                user.reauthenticate(with: credential) { [weak self] _, error in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }
                    
                    if let error = error {
                        completion(false, "Authentication failed: \(error.localizedDescription)")
                        continuation.resume()
                        return
                    }
                    
                    let userId = user.uid
                    UserService.shared.deleteUserProfile(userID: userId) { error in
                        if let error = error {
                            print("Error deleting Firestore data: \(error.localizedDescription)")
                        }
                    }
                    
                    CoreDataManager.shared.clearUserData()
                    
                    user.delete { error in
                        if let error = error {
                            completion(false, "Failed to delete account: \(error.localizedDescription)")
                        } else {
                            completion(true, nil)
                            self.logout()
                        }
                        continuation.resume()
                    }
                }
            }
        }
    }
}

// MARK: - Task Count Updates
extension ProfileViewModel {
    func updateTaskStatistics(completed: Int, remaining: Int) {
        Task { @MainActor in
            await updateTaskCounts(done: completed, left: remaining)
        }
    }
}
