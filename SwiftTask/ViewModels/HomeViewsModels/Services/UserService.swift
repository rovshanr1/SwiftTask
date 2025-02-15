//
//  UserServices.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 05.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    func fetchUserProfile(userID: String, completion: @escaping (ProfileModel?) -> Void) {
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let profile = ProfileModel(
                    userName: data?["name"] as? String ?? "No Name",
                    taskLeft: data?["taskLeft"] as? Int ?? 0,
                    taskDone: data?["taskDone"] as? Int ?? 0,
                    email: data?["email"] as? String ?? "",
                    timestamp: data?["timestamp"] as? Date ?? Date()
                )
                completion(profile)
            } else {
                completion(nil)
            }
        }
    }

    
    func saveUserProfile(userID: String, profile: ProfileModel, completion: ((Error?) -> Void)? = nil) {
        let userRef = db.collection("users").document(userID)
        let userData: [String: Any] = [
            "name": profile.userName,
            "taskLeft": profile.taskLeft,
            "taskDone": profile.taskDone,
            "email": profile.email,
            "timestamp": FieldValue.serverTimestamp()
        ]
        userRef.setData(userData, merge: true, completion: completion)
    }
}

