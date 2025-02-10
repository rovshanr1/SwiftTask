import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var completedTasks: [Item] = []
    @Published var newItems: [Item] = []
    @Published var isTodayExpanded = true
    @Published var isCompletedExpanded = true
    @Published var isLoading: Bool = false
    @Published var taskDoneCount: Int = 0
    @Published var taskLeftCount: Int = 0
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchItems()
    }
    
    func fetchItems() {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            do {
                items = try context.fetch(request)
                
                // Update filtered lists
//                let today = Calendar.current.startOfDay(for: Date())
                completedTasks = items.filter { $0.completed }
                newItems = items.filter { !$0.completed }
                
                // Update task counts
                updateTaskCounts()
                
                // Notify observers
                objectWillChange.send()
            } catch {
                print("Fetch items error: \(error.localizedDescription)")
            }
        }
    
    private func updateTaskCounts() {
            let today = Calendar.current.startOfDay(for: Date())
            let todayTasks = items.filter { Calendar.current.startOfDay(for: $0.date ?? Date()) == today }
            
            taskDoneCount = todayTasks.filter { $0.completed }.count
            taskLeftCount = todayTasks.filter { !$0.completed }.count
            
            // Post notification for profile view update
            NotificationCenter.default.post(
                name: .tasksUpdated,
                object: nil,
                userInfo: [
                    "taskDone": taskDoneCount,
                    "taskLeft": taskLeftCount
                ]
            )
        }
    
    func addTask(title: String, description: String, date: Date?) {
            let newItem = Item(context: context)
            newItem.title = title
            newItem.taskDescription = description
            newItem.date = date ?? Date()
            newItem.id = UUID()
            newItem.completed = false
            
            saveContext()
        }

    
    func deleteSingleTask(_ item: Item) {
        context.delete(item)
        saveContext()
    }
    
    func editTask(item: Item, newTitle: String, newDescription: String) {
        item.title = newTitle
        item.taskDescription = newDescription
        saveContext()
    }
    
    func toggleTaskCompletion(_ item: Item) {
        item.completed.toggle()
        saveContext()
        fetchItems()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchItems()  // Refresh the list after saving
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
}


