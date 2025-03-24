import Foundation
import CoreData
import FirebaseFirestore

struct DailyFocus: Codable, Identifiable {
    let id: String
    let date: Date
    var duration: TimeInterval
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration, userId
    }
    
    init(id: String = UUID().uuidString, date: Date, duration: TimeInterval, userId: String) {
        self.id = id
        self.date = date
        self.duration = duration
        self.userId = userId
    }
    
    // CoreData'dan DailyFocus oluşturma
    init(from entity: FocusEntity) {
        self.id = entity.id ?? UUID().uuidString
        self.date = entity.date ?? Date()
        self.duration = entity.duration
        self.userId = entity.userId ?? ""
    }
    
    // Firestore dictionary'den oluşturma
    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let date = (dict["date"] as? Timestamp)?.dateValue(),
              let duration = dict["duration"] as? TimeInterval,
              let userId = dict["userId"] as? String else {
            return nil
        }
        
        self.id = id
        self.date = date
        self.duration = duration
        self.userId = userId
    }
    
    // Firestore için dictionary
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "date": Timestamp(date: date),
            "duration": duration,
            "userId": userId
        ]
    }
} 