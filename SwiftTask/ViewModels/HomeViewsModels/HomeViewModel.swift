import CoreData
import SwiftUI
import FirebaseAuth

enum TaskCategory: String, CaseIterable {
    case all = "All"
    case grocery = "Grocery"
    case work = "Work"
    case sport = "Sport"
    case design = "Design"
    case university = "University"
    case social = "Social"
    case music = "Music"
    case health = "Health"
    case movie = "Movie"
    case home = "Home"
    case personal = "Personal"
    case shopping = "Shopping"
    case others = "Others"
    
    var color: Color {
        switch self {
        case .all: return ThemeManager.shared.currentTheme.accent
        case .grocery: return Color(red: 0.95, green: 0.33, blue: 0.33)
        case .work: return Color(red: 0.97, green: 0.58, blue: 0.02)
        case .sport: return Color(red: 0.06, green: 0.71, blue: 0.35)
        case .design: return Color(red: 0.0, green: 0.48, blue: 1.0)
        case .university: return Color(red: 0.54, green: 0.0, blue: 1.0)
        case .social: return Color(red: 0.91, green: 0.0, blue: 0.54)
        case .music: return Color(red: 0.0, green: 0.78, blue: 0.81)
        case .health: return Color(red: 0.0, green: 0.73, blue: 0.45)
        case .movie: return Color(red: 0.85, green: 0.0, blue: 0.0)
        case .home: return Color(red: 0.0, green: 0.47, blue: 0.99)
        case .personal: return ThemeManager.shared.currentTheme.accent
        case .shopping: return ThemeManager.shared.currentTheme.accent
        case .others: return ThemeManager.shared.currentTheme.secondaryText
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .grocery: return "cart"
        case .work: return "briefcase"
        case .sport: return "figure.run"
        case .design: return "paintbrush"
        case .university: return "book"
        case .social: return "person.2"
        case .music: return "music.note"
        case .health: return "heart"
        case .movie: return "film"
        case .home: return "house"
        case .personal: return "person"
        case .shopping: return "bag"
        case .others: return "ellipsis"
        }
    }
}

enum TaskPriority: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return Color(red: 0.06, green: 0.71, blue: 0.35)
        case .medium: return ThemeManager.shared.currentTheme.accent
        case .high: return Color(red: 0.95, green: 0.33, blue: 0.33)
        }
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var completedTasks: [Item] = []
    @Published var newItems: [Item] = []
    @Published var isTodayExpanded = true
    @Published var isCompletedExpanded = true
    @Published var isLoading: Bool = false
    @Published var taskDoneCount: Int = 0
    @Published var taskLeftCount: Int = 0
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var profileImageData: Data? = nil
    @Published var userName: String = ""
    @Published var selectedCategory: TaskCategory?
    @Published var selectedPriority: TaskPriority?
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let context: NSManagedObjectContext
    private let taskService = TaskService.shared
    private let notificationService = NotificationService.shared
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { item in
                let titleMatch = item.title?.localizedCaseInsensitiveContains(searchText) ?? false
                let descriptionMatch = item.taskDescription?.localizedCaseInsensitiveContains(searchText) ?? false
                return titleMatch || descriptionMatch
            }
        }
    }
    
    var filteredNewItems: [Item] {
        filteredItems.filter { !$0.completed }
    }
    
    var filteredCompletedTasks: [Item] {
        filteredItems.filter { $0.completed }
    }
    
    // Tüm görevler için sayılar
    var totalTasksLeft: Int {
        newItems.count
    }
    
    var totalTasksDone: Int {
        completedTasks.count
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchItems()
        fetchUserProfile()
        
        // Start syncing with Firebase
        startSyncing()
        
        // Listen for profile updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileUpdated),
            name: .profileUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileUpdated),
            name: .tasksUpdated,
            object: nil
        )
        
        // Notification observers for reminders
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDailyReminderTapped),
            name: .dailyReminderTapped,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskReminderTapped(_:)),
            name: .taskReminderTapped,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func profileUpdated() {
        DispatchQueue.main.async {
            self.fetchUserProfile()
        }
    }
    
    func fetchUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if let profile = CoreDataManager.shared.fetchUserProfile(userId: userID) {
            DispatchQueue.main.async {
                self.userName = profile.userName
            }
        }
        
        if let imageData = CoreDataManager.shared.fetchProfileImage(userId: userID) {
            DispatchQueue.main.async {
                self.profileImageData = imageData
            }
        }
    }
    
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            items = try context.fetch(request)
            completedTasks = items.filter { $0.completed }
            newItems = items.filter { !$0.completed }
            updateTaskCounts()
            objectWillChange.send()
        } catch {
            print("Fetch items error: \(error.localizedDescription)")
        }
    }
    
    private func updateTaskCounts() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter today's tasks
        let todayTasks = items.filter { item in
            if let taskDate = item.date {
                let taskDay = calendar.startOfDay(for: taskDate)
                return taskDay == today
            }
            return false
        }
        
        // Count completed and remaining tasks for today
        taskDoneCount = todayTasks.filter { $0.completed }.count
        taskLeftCount = todayTasks.filter { !$0.completed }.count
        
        // Update UI
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        // Notify other views
        NotificationCenter.default.post(
            name: .tasksUpdated,
            object: nil,
            userInfo: [
                "taskDone": taskDoneCount,
                "taskLeft": taskLeftCount
            ]
        )
    }
    
    private func startSyncing() {
        Task {
            do {
                isLoading = true
                try await taskService.syncTasks(context: context)
                isLoading = false
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = if let taskError = error as? TaskServiceError {
            switch taskError {
            case .userNotFound:
                "User not found. Please login again."
            case .saveFailed:
                "Failed to save task."
            case .updateFailed:
                "Failed to update task."
            case .deleteFailed:
                "Failed to delete task."
            case .invalidTaskId:
                "Invalid task identifier."
            case .firebaseError(let error):
                "Firebase error: \(error.localizedDescription)"
            case .coreDataError(let error):
                "Database error: \(error.localizedDescription)"
            }
        } else {
            error.localizedDescription
        }
        showError = true
    }
    
    func addTask(title: String, description: String, date: Date?, category: TaskCategory? = nil, priority: TaskPriority? = nil) {
        Task {
            do {
                isLoading = true
                try await taskService.addTask(
                    title: title,
                    description: description,
                    date: date ?? Date(),
                    category: category,
                    priority: priority,
                    context: context
                )
                
                // Schedule notification for new task
                let settings = NotificationSettingsModel.loadFromUserDefaults()
                if settings.taskDueReminder, let lastTask = try? context.fetch(Item.fetchRequest()).last {
                    try await notificationService.scheduleTaskReminder(for: lastTask, context: context)
                }
                
                isLoading = false
                fetchItems()
                updateTaskCounts()
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
    
    func deleteSingleTask(_ item: Item) {
        Task {
            do {
                isLoading = true
                
                // Cancel notification first
                if let taskId = item.id?.uuidString {
                    notificationService.cancelTaskReminder(for: taskId)
                }
                
                try await taskService.deleteTask(item: item, context: context)
                isLoading = false
                fetchItems()
                updateTaskCounts()
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
    
    func editTask(item: Item, newTitle: String, newDescription: String, category: TaskCategory? = nil, priority: TaskPriority? = nil) {
        Task {
            do {
                isLoading = true
                try await taskService.updateTask(
                    item: item,
                    title: newTitle,
                    description: newDescription,
                    category: category,
                    priority: priority,
                    context: context
                )
                
                // Update task notification
                let settings = NotificationSettingsModel.loadFromUserDefaults()
                if settings.taskDueReminder {
                    if let taskId = item.id?.uuidString {
                        notificationService.cancelTaskReminder(for: taskId)
                    }
                    try await notificationService.scheduleTaskReminder(for: item, context: context)
                }
                
                isLoading = false
                fetchItems()
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
    
    func toggleTaskCompletion(_ item: Item) {
        Task {
            do {
                print("Toggling task completion - Before: \(item.completed)")
                isLoading = true
                try await taskService.toggleTaskCompletion(item: item, context: context)
                
                // Cancel notification if task is completed
                if item.completed, let taskId = item.id?.uuidString {
                    notificationService.cancelTaskReminder(for: taskId)
                }
                
                await MainActor.run {
                    isLoading = false
                    fetchItems()
                    updateTaskCounts()
                    print("Task completion toggled - After: \(item.completed)")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    handleError(error)
                    print("Error toggling task completion: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Notification Handlers
    @objc private func handleDailyReminderTapped() {
        // Actions to perform when daily reminder is tapped
        fetchItems() // Refresh tasks
    }
    
    @objc private func handleTaskReminderTapped(_ notification: Notification) {
        guard let taskId = notification.userInfo?["taskId"] as? String else { return }
        
        // Actions to perform when task reminder is tapped
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", taskId)
        request.fetchLimit = 1
        
        do {
            if let task = try context.fetch(request).first {
                // Mark or display the relevant task
                print("Task reminder tapped for: \(task.title ?? "")")
                // Additional actions can be performed here to highlight or display the task
            }
        } catch {
            print("Error fetching task: \(error)")
        }
    }
}

extension Notification.Name {
    // In-app notifications
    static let tasksUpdated = Notification.Name("tasksUpdated")
    static let profileUpdated = Notification.Name("profileUpdated")
    static let userSignedOut = Notification.Name("userSignedOut")
    
    // User notifications
    static let dailyReminderTapped = Notification.Name("dailyReminderTapped")
    static let taskReminderTapped = Notification.Name("taskReminderTapped")
}


