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
import CoreData
import Network

class OfflineSyncManager {
    static let shared = OfflineSyncManager()
    private var offlineQueue: [[String: Any]] = []
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published private(set) var isOnline = true
    private var pendingOperations: [PendingOperation] = []
    
    private init() {
        setupNetworkMonitoring()
    }
    
    struct PendingOperation: Codable {
        enum OperationType: String, Codable {
            case add, update, delete, toggleComplete
        }
        
        let type: OperationType
        let taskId: String
        let taskData: [String: Any]
        
        enum CodingKeys: String, CodingKey {
            case type, taskId, taskData
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(taskId, forKey: .taskId)
            try container.encode(taskData.mapValues { "\($0)" }, forKey: .taskData)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(OperationType.self, forKey: .type)
            taskId = try container.decode(String.self, forKey: .taskId)
            let stringData = try container.decode([String: String].self, forKey: .taskData)
            taskData = stringData.mapValues { $0 }
        }
        
        init(type: OperationType, taskId: String, taskData: [String: Any]) {
            self.type = type
            self.taskId = taskId
            self.taskData = taskData
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if self?.isOnline == true {
                    self?.syncPendingOperations()
                }
            }
        }
        networkMonitor.start(queue: queue)
    }
    
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
    
    func addPendingOperation(_ operation: PendingOperation) {
        pendingOperations.append(operation)
        savePendingOperations()
    }
    
    private func savePendingOperations() {
        do {
            let data = try JSONEncoder().encode(pendingOperations)
            UserDefaults.standard.set(data, forKey: "PendingOperations")
        } catch {
            print("Pending operasyonları kaydetme hatası: \(error)")
        }
    }
    
    private func loadPendingOperations() {
        guard let data = UserDefaults.standard.data(forKey: "PendingOperations") else { return }
        do {
            pendingOperations = try JSONDecoder().decode([PendingOperation].self, from: data)
        } catch {
            print("Pending operasyonları yükleme hatası: \(error)")
        }
    }
    
    private func syncPendingOperations() {
        guard !pendingOperations.isEmpty else { return }
        
        Task {
            for operation in pendingOperations {
                do {
                    switch operation.type {
                    case .add:
                        try await TaskService.shared.syncAddTask(taskId: operation.taskId, taskData: operation.taskData)
                    case .update:
                        try await TaskService.shared.syncUpdateTask(taskId: operation.taskId, taskData: operation.taskData)
                    case .delete:
                        try await TaskService.shared.syncDeleteTask(taskId: operation.taskId)
                    case .toggleComplete:
                        try await TaskService.shared.syncToggleComplete(taskId: operation.taskId, taskData: operation.taskData)
                    }
                    
                    if let index = pendingOperations.firstIndex(where: { $0.taskId == operation.taskId }) {
                        pendingOperations.remove(at: index)
                        savePendingOperations()
                    }
                } catch {
                    print("Senkronizasyon hatası: \(error)")
                }
            }
        }
    }
}

