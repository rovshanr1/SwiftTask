import Foundation
import CoreData

@objc(FocusEntity)
public class FocusEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: TimeInterval
    @NSManaged public var userId: String?
}

extension FocusEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusEntity> {
        return NSFetchRequest<FocusEntity>(entityName: "FocusEntity")
    }
    
    static func create(in context: NSManagedObjectContext,
                      id: String,
                      date: Date,
                      duration: TimeInterval,
                      userId: String) -> FocusEntity {
        let entity = FocusEntity(context: context)
        entity.id = id
        entity.date = date
        entity.duration = duration
        entity.userId = userId
        return entity
    }
    
    func update(duration: TimeInterval) {
        self.duration = duration
    }
} 