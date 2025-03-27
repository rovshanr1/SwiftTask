import Foundation

struct NotificationSettingsModel: Codable {
    var isEnabled: Bool
    var dailyReminder: Bool
    var reminderTime: Date
    var taskDueReminder: Bool
    var soundEnabled: Bool
    var vibrationEnabled: Bool
    
    static let `default` = NotificationSettingsModel(
        isEnabled: false,
        dailyReminder: false,
        reminderTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        taskDueReminder: false,
        soundEnabled: true,
        vibrationEnabled: true
    )
    
    private static let settingsKey = "notificationSettings"
    
    static func loadFromUserDefaults() -> NotificationSettingsModel {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(NotificationSettingsModel.self, from: data)
        else {
            return .default
        }
        return settings
    }
    
    func saveToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encodedData, forKey: Self.settingsKey)
        }
    }
} 