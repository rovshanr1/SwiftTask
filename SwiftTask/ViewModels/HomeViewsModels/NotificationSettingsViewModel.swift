import Foundation
import UserNotifications
import CoreData

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var settings: NotificationSettingsModel
    private let context: NSManagedObjectContext
    private let notificationService = NotificationService.shared
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.settings = NotificationSettingsModel.loadFromUserDefaults()
    }
    
    func requestNotificationPermission() {
        Task {
            do {
                let granted = try await notificationService.requestAuthorization()
                settings.isEnabled = granted
                if granted {
                    try await updateNotificationSchedules()
                } else {
                    cancelAllNotifications()
                }
                settings.saveToUserDefaults()
            } catch {
                print("Failed to request notification permission: \(error)")
                settings.isEnabled = false
                settings.saveToUserDefaults()
            }
        }
    }
    
    func checkNotificationStatus() {
        Task {
            let isAuthorized = await notificationService.checkAuthorizationStatus()
            await MainActor.run {
                settings.isEnabled = isAuthorized
                settings.saveToUserDefaults()
            }
        }
    }
    
    func toggleDailyReminder() {
        settings.dailyReminder.toggle()
        Task {
            do {
                if settings.dailyReminder {
                    try await notificationService.scheduleDailyReminder(at: settings.reminderTime, context: context)
                } else {
                    notificationService.cancelDailyReminder()
                }
                settings.saveToUserDefaults()
            } catch {
                print("Failed to set daily reminder: \(error)")
                settings.dailyReminder = false
                settings.saveToUserDefaults()
            }
        }
    }
    
    func updateReminderTime(_ newTime: Date) {
        settings.reminderTime = newTime
        if settings.dailyReminder {
            Task {
                do {
                    try await notificationService.scheduleDailyReminder(at: newTime, context: context)
                    settings.saveToUserDefaults()
                } catch {
                    print("Failed to update reminder time: \(error)")
                }
            }
        }
    }
    
    func toggleTaskDueReminder() {
        settings.taskDueReminder.toggle()
        Task {
            do {
                if settings.taskDueReminder {
                    try await updateTaskReminders()
                } else {
                    await cancelAllTaskReminders()
                }
                settings.saveToUserDefaults()
            } catch {
                print("Failed to update task reminders: \(error)")
                settings.taskDueReminder = false
                settings.saveToUserDefaults()
            }
        }
    }
    
    func toggleSound() {
        settings.soundEnabled.toggle()
        Task {
            do {
                try await updateNotificationSchedules()
                settings.saveToUserDefaults()
            } catch {
                print("Failed to update sound settings: \(error)")
            }
        }
    }
    
    func toggleVibration() {
        settings.vibrationEnabled.toggle()
        settings.saveToUserDefaults()
    }
    
    private func updateNotificationSchedules() async throws {
        if settings.dailyReminder {
            try await notificationService.scheduleDailyReminder(at: settings.reminderTime, context: context)
        }
        if settings.taskDueReminder {
            try await updateTaskReminders()
        }
    }
    
    private func updateTaskReminders() async throws {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "completed == NO AND date > %@", Date() as NSDate)
        
        let tasks = try context.fetch(request)
        for task in tasks {
            try await notificationService.scheduleTaskReminder(for: task, context: context)
        }
    }
    
    private func cancelAllTaskReminders() async {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let tasks = try? context.fetch(request)
        
        for task in tasks ?? [] {
            if let taskId = task.id?.uuidString {
                notificationService.cancelTaskReminder(for: taskId)
            }
        }
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 