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
    
    init() {
        fetchUserData()
        fetchProfileImage()
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

    func logout() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}
