import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
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
        } catch {
            print("Veri çekme hatası: \(error.localizedDescription)")
        }
    }
    
    func addTask(title: String, description: String) {
        let newItem = Item(context: context)
        newItem.title = title
        newItem.taskDescription = description
        newItem.id = UUID()
        newItem.date = Date()
        
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Add new task error: \(error.localizedDescription)")
        }
    }
    
    func deleteSingleTask(_ item: Item) {
        context.delete(item)
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Delete Error: \(error.localizedDescription)")
        }
    }
}

