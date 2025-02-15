//
//  OfflineSyncManager.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 05.02.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class OfflineSyncManager {
    static let shared = OfflineSyncManager()
    private var offlineQueue: [[String: Any]] = []
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    func addToQueue(data: [String: Any]) {
        offlineQueue.append(data)
    }
    
    func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundTask()
        })
    }
    
    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func retryOfflineSync() {
        guard NetworkService.shared.isConnectedToNetwork() else { return }
        
        startBackgroundTask()
        
        while !offlineQueue.isEmpty {
            let userData = offlineQueue.removeFirst()
            guard let userID = Auth.auth().currentUser?.uid else { return }
            let userRef = Firestore.firestore().collection("users").document(userID)
            
            userRef.setData(userData, merge: true) { error in
                if let error = error {
                    print("Retry sync error: \(error.localizedDescription)")
                    self.offlineQueue.append(userData)
                } else {
                    print("Offline sync success")
                }
            }
        }
        
        endBackgroundTask()
    }
}

