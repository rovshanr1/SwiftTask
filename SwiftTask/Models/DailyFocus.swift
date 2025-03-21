import Foundation

struct DailyFocus: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var duration: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration
    }
} 