import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var completedTasks: [Item] = []
    @Published var newItems: [Item] = []
    @Published var isTodayExpanded = true
    @Published var isCompletedExpanded = true
    @Published var isLoading: Bool = false
    
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
            newItems = items.filter { !$0.completed }
            completedTasks = items.filter { $0.completed }
        } catch {
            print("Fetch items error: \(error.localizedDescription)")
        }
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
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
}
