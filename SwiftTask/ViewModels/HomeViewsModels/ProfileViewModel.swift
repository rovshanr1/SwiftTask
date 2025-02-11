//
//  ProfileViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

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
   
    private let context = PersistenceController.shared.viewContext
    
    init() {
        fetchUserData()
        fetchProfileImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTaskCounts(_:)), name: .tasksUpdated, object: nil)
    }
    
    @objc private func updateTaskCounts(_ notification: Notification) {
           if let taskDone = notification.userInfo?["taskDone"] as? Int,
              let taskLeft = notification.userInfo?["taskLeft"] as? Int {
               DispatchQueue.main.async {
                   self.user?.taskDone = taskDone
                   self.user?.taskLeft = taskLeft
               }
           }
       }
    
    func fetchUserData() {
        isLoading = true
        guard let userID = Auth.auth().currentUser?.uid else { return }
 
        if let cachedProfile = CoreDataManager.shared.fetchUserProfile(userId: userID) {
            DispatchQueue.main.async {
                self.user = cachedProfile
            }
        }
        
       
        UserService.shared.fetchUserProfile(userID: userID) { profile in
            DispatchQueue.main.async {
                if let profile = profile {
                    self.user = profile
                    CoreDataManager.shared.saveUserProfile(userId: userID, profile: profile)
                }
                self.isLoading = false
            }
        }
    }
    
    func saveUserProfile(name: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let updatedProfile = ProfileModel(
            userName: name,
            taskLeft: user?.taskLeft ?? 0,
            taskDone: user?.taskDone ?? 0,
            email: user?.email ?? ""
        )
        
        CoreDataManager.shared.saveUserProfile(userId: userID, profile: updatedProfile)
        
        UserService.shared.saveUserProfile(userID: userID, profile: updatedProfile) { error in
            if let error = error {
                print("Firebase update error: \(error.localizedDescription)")
                OfflineSyncManager.shared.addToQueue(data: [
                    "name": name
                ])
            } else {
                print("Profile updated in Firestore")
            }
        }
    }
    
    func loadImage(from item: PhotosPickerItem) {
        isLoading = true
        ImageService.shared.loadImage(from: item) { data in
            DispatchQueue.main.async {
                if let data = data {
                    self.profileImageData = data
                    CoreDataManager.shared.saveProfileImage(userId: Auth.auth().currentUser?.uid ?? "", imageData: data)
                }
                self.isLoading = false
            }
        }
    }
    
    func fetchProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let imageData = CoreDataManager.shared.fetchProfileImage(userId: userID)
        
        DispatchQueue.main.async {
            self.profileImageData = imageData
        }
    }
    
    func updateProfileImage(_ image: UIImage) {
        DispatchQueue.global(qos: .background).async {
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                CoreDataManager.shared.saveProfileImage(userId: Auth.auth().currentUser?.uid ?? "", imageData: imageData)

                DispatchQueue.main.async {
                    self.profileImageData = imageData
                }
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "User not found.")
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        //Authenticate the user again
        user.reauthenticate(with: credential) { _, error in
            if error != nil {
                completion(false, "Current password is incorrect.")
                return
            }

            //Update new password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    // Deleting Profile Image
    func removeProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
       
        DispatchQueue.main.async {
            self.profileImageData = nil
        }
        // Remove from CoreData
        CoreDataManager.shared.deleteProfileImage(userId: userID)
    }

    
    func logout() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}
