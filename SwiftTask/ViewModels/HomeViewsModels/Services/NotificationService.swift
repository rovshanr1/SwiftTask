import Foundation
import UserNotifications
import CoreData

enum NotificationServiceError: Error {
    case notificationNotAuthorized
    case failedToSchedule
    case taskNotFound
    case invalidDate
}

class NotificationService {
    static let shared = NotificationService()
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Notification Authorization
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        return try await notificationCenter.requestAuthorization(options: options)
    }
    
    func checkAuthorizationStatus() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Daily Reminders
    func scheduleDailyReminder(at time: Date, context: NSManagedObjectContext) async throws {
        let isAuthorized = await checkAuthorizationStatus()
        guard isAuthorized else { throw NotificationServiceError.notificationNotAuthorized }
        
        // Clear existing daily reminder first
        removePendingNotifications(withIdentifiers: ["dailyReminder"])
        
        let content = UNMutableNotificationContent()
        let todaysTasks = fetchTodaysTasks(context: context)
        
        content.title = "Daily Task Reminder"
        if todaysTasks.isEmpty {
            content.body = "You have no tasks planned for today. Would you like to add a new task?"
        } else {
            let completedCount = todaysTasks.filter { $0.completed }.count
            let remainingCount = todaysTasks.count - completedCount
            content.body = "You have \(remainingCount) tasks remaining and \(completedCount) tasks completed today."
        }
        
        let settings = NotificationSettingsModel.loadFromUserDefaults()
        content.sound = settings.soundEnabled ? .default : nil
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: time)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        try await notificationCenter.add(request)
    }
    
    func cancelDailyReminder() {
        removePendingNotifications(withIdentifiers: ["dailyReminder"])
    }
    
    // MARK: - Task Reminders
    func scheduleTaskReminder(for task: Item, context: NSManagedObjectContext) async throws {
        let isAuthorized = await checkAuthorizationStatus()
        guard isAuthorized else { throw NotificationServiceError.notificationNotAuthorized }
        guard let dueDate = task.date else { throw NotificationServiceError.invalidDate }
        guard let taskId = task.id?.uuidString else { throw NotificationServiceError.taskNotFound }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Due date approaching for: \(task.title ?? "Task")!"
        
        let settings = NotificationSettingsModel.loadFromUserDefaults()
        content.sound = settings.soundEnabled ? .default : nil
        
        // Schedule notification 1 hour before the due date
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate) ?? dueDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "taskReminder-\(taskId)", content: content, trigger: trigger)
        
        try await notificationCenter.add(request)
    }
    
    func cancelTaskReminder(for taskId: String) {
        removePendingNotifications(withIdentifiers: ["taskReminder-\(taskId)"])
    }
    
    // MARK: - Helpers
    private func fetchTodaysTasks(context: NSManagedObjectContext) -> [Item] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching today's tasks: \(error)")
            return []
        }
    }
    
    private func removePendingNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Notification Handling
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let identifier = response.notification.request.identifier
        
        if identifier == "dailyReminder" {
            NotificationCenter.default.post(name: .dailyReminderTapped, object: nil)
        } else if identifier.starts(with: "taskReminder-") {
            let taskId = String(identifier.dropFirst("taskReminder-".count))
            NotificationCenter.default.post(
                name: .taskReminderTapped,
                object: nil,
                userInfo: ["taskId": taskId]
            )
        }
    }
} 