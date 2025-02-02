import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "SwiftTask")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                print("Core Data yükleme hatası: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
