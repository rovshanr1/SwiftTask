import Foundation
import FirebaseDatabase
import FirebaseAuth
import CoreData

enum TaskServiceError: Error {
    case userNotFound
    case saveFailed
    case updateFailed
    case deleteFailed
    case invalidTaskId
    case firebaseError(Error)
    case coreDataError(Error)
}

// Move shared instance outside of MainActor isolation
final class TaskService {
    static let shared = TaskService()
    private let database = Database.database().reference()
    private let coreDataManager = CoreDataManager.shared
    private let offlineSyncManager = OfflineSyncManager.shared
    
    private init() {}
    
    // MARK: - Firebase Operations
    
    @MainActor
    func syncTasks(context: NSManagedObjectContext) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        // Listen for real-time updates
        database.child("users").child(userId).child("tasks").observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let tasksDict = snapshot.value as? [String: [String: Any]] else { return }
            
            Task { @MainActor in
                try? await self.updateLocalTasks(with: tasksDict, context: context)
            }
        }
    }
    
    @MainActor
    func addTask(title: String, description: String, date: Date, category: TaskCategory?, priority: TaskPriority?, context: NSManagedObjectContext) async throws {
        let taskId = UUID().uuidString
        let taskData: [String: Any] = [
            "id": taskId,
            "title": title,
            "description": description,
            "date": date.timeIntervalSince1970,
            "completed": false,
            "category": category?.rawValue ?? "",
            "priority": priority?.rawValue ?? 0
        ]
        
        // Önce CoreData'ya kaydet
        let newItem = Item(context: context)
        newItem.id = UUID(uuidString: taskId)
        newItem.title = title
        newItem.taskDescription = description
        newItem.date = date
        newItem.completed = false
        newItem.category = category?.rawValue
        newItem.priority = Int16(priority?.rawValue ?? 0)
        
        do {
            try context.save()
            
            // Firebase'e kaydetmeyi dene
            if offlineSyncManager.isOnline {
                try await syncAddTask(taskId: taskId, taskData: taskData)
            } else {
                // Çevrimdışıysa pending operasyonlara ekle
                offlineSyncManager.addPendingOperation(
                    .init(type: .add, taskId: taskId, taskData: taskData)
                )
            }
        } catch {
            throw TaskServiceError.saveFailed
        }
    }
    
    @MainActor
    func updateTask(item: Item, title: String, description: String, category: TaskCategory?, priority: TaskPriority?, context: NSManagedObjectContext) async throws {
        guard let taskId = item.id?.uuidString else {
            throw TaskServiceError.invalidTaskId
        }
        
        let taskData: [String: Any] = [
            "title": title,
            "description": description,
            "category": category?.rawValue ?? "",
            "priority": priority?.rawValue ?? 0,
            "completed": item.completed
        ]
        
        // Önce CoreData'yı güncelle
        item.title = title
        item.taskDescription = description
        item.category = category?.rawValue
        item.priority = Int16(priority?.rawValue ?? 0)
        
        do {
            try context.save()
            
            // Firebase'i güncellemeyi dene
            if offlineSyncManager.isOnline {
                try await syncUpdateTask(taskId: taskId, taskData: taskData)
            } else {
                // Çevrimdışıysa pending operasyonlara ekle
                offlineSyncManager.addPendingOperation(
                    .init(type: .update, taskId: taskId, taskData: taskData)
                )
            }
        } catch {
            throw TaskServiceError.updateFailed
        }
    }
    
    @MainActor
    func deleteTask(item: Item, context: NSManagedObjectContext) async throws {
        guard let taskId = item.id?.uuidString else {
            throw TaskServiceError.invalidTaskId
        }
        
        // Önce CoreData'dan sil
        context.delete(item)
        do {
            try context.save()
            
            // Firebase'den silmeyi dene
            if offlineSyncManager.isOnline {
                try await syncDeleteTask(taskId: taskId)
            } else {
                // Çevrimdışıysa pending operasyonlara ekle
                offlineSyncManager.addPendingOperation(
                    .init(type: .delete, taskId: taskId, taskData: [:])
                )
            }
        } catch {
            throw TaskServiceError.deleteFailed
        }
    }
    
    @MainActor
    func toggleTaskCompletion(item: Item, context: NSManagedObjectContext) async throws {
        guard let taskId = item.id?.uuidString else {
            throw TaskServiceError.invalidTaskId
        }
        
        let newCompletionState = !item.completed
        let taskData: [String: Any] = ["completed": newCompletionState]
        
        // Önce CoreData'yı güncelle
        item.completed = newCompletionState
        do {
            try context.save()
            
            // Firebase'i güncellemeyi dene
            if offlineSyncManager.isOnline {
                try await syncToggleComplete(taskId: taskId, taskData: taskData)
            } else {
                // Çevrimdışıysa pending operasyonlara ekle
                offlineSyncManager.addPendingOperation(
                    .init(type: .toggleComplete, taskId: taskId, taskData: taskData)
                )
            }
        } catch {
            throw TaskServiceError.updateFailed
        }
    }
    
    // MARK: - Firebase Sync Operations
    
    func syncAddTask(taskId: String, taskData: [String: Any]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            database.child("users").child(userId).child("tasks").child(taskId).setValue(taskData) { error, _ in
                if let error = error {
                    continuation.resume(throwing: TaskServiceError.firebaseError(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func syncUpdateTask(taskId: String, taskData: [String: Any]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            database.child("users").child(userId).child("tasks").child(taskId).updateChildValues(taskData) { error, _ in
                if let error = error {
                    continuation.resume(throwing: TaskServiceError.firebaseError(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func syncDeleteTask(taskId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            database.child("users").child(userId).child("tasks").child(taskId).removeValue { error, _ in
                if let error = error {
                    continuation.resume(throwing: TaskServiceError.firebaseError(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func syncToggleComplete(taskId: String, taskData: [String: Any]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskServiceError.userNotFound
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            database.child("users").child(userId).child("tasks").child(taskId).updateChildValues(taskData) { error, _ in
                if let error = error {
                    continuation.resume(throwing: TaskServiceError.firebaseError(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func updateLocalTasks(with tasksDict: [String: [String: Any]], context: NSManagedObjectContext) async throws {
        // Fetch existing tasks
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let existingTasks = try context.fetch(fetchRequest)
        
        // Create a set of existing task IDs
        let existingTaskIds = Set(existingTasks.compactMap { $0.id?.uuidString })
        
        for (taskId, taskData) in tasksDict {
            if let title = taskData["title"] as? String,
               let description = taskData["description"] as? String,
               let timestamp = taskData["date"] as? TimeInterval,
               let completed = taskData["completed"] as? Bool {
                
                let date = Date(timeIntervalSince1970: timestamp)
                
                if existingTaskIds.contains(taskId) {
                    // Update existing task
                    if let existingTask = existingTasks.first(where: { $0.id?.uuidString == taskId }) {
                        existingTask.title = title
                        existingTask.taskDescription = description
                        existingTask.date = date
                        existingTask.completed = completed
                        existingTask.category = taskData["category"] as? String
                        if let priority = taskData["priority"] as? Int {
                            existingTask.priority = Int16(priority)
                        }
                    }
                } else {
                    // Create new task
                    let newTask = Item(context: context)
                    newTask.id = UUID(uuidString: taskId)
                    newTask.title = title
                    newTask.taskDescription = description
                    newTask.date = date
                    newTask.completed = completed
                    newTask.category = taskData["category"] as? String
                    if let priority = taskData["priority"] as? Int {
                        newTask.priority = Int16(priority)
                    }
                }
            }
        }
        
        // Delete tasks that no longer exist in Firebase
        let firebaseTaskIds = Set(tasksDict.keys)
        let tasksToDelete = existingTasks.filter { task in
            guard let taskId = task.id?.uuidString else { return false }
            return !firebaseTaskIds.contains(taskId)
        }
        
        for task in tasksToDelete {
            context.delete(task)
        }
        
        try context.save()
    }
} 