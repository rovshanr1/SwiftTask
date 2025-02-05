import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchItems()
    }
    
    func saveContext() {
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
    
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            items = try context.fetch(request)
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
}


