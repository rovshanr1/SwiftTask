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
        case .all: return .purple
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
        case .personal: return .green
        case .shopping: return .orange
        case .others: return .gray
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
    case urgent = 4
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return Color(red: 0.06, green: 0.71, blue: 0.35)
        case .medium: return Color(red: 0.97, green: 0.58, blue: 0.02)
        case .high: return Color(red: 0.95, green: 0.33, blue: 0.33)
        case .urgent: return Color.red
        }
    }
}

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
    
    private let context: NSManagedObjectContext
    
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
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchItems()
        fetchUserProfile()
        
        // Profil değişikliklerini dinle
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
        
        // Profil fotoğrafını çek
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
                
                // Update filtered lists
//                let today = Calendar.current.startOfDay(for: Date())
                completedTasks = items.filter { $0.completed }
                newItems = items.filter { !$0.completed }
                
                // Update task counts
                updateTaskCounts()
                
                // Notify observers
                objectWillChange.send()
            } catch {
                print("Fetch items error: \(error.localizedDescription)")
            }
        }
    
    private func updateTaskCounts() {
            let today = Calendar.current.startOfDay(for: Date())
            let todayTasks = items.filter { Calendar.current.startOfDay(for: $0.date ?? Date()) == today }
            
            taskDoneCount = todayTasks.filter { $0.completed }.count
            taskLeftCount = todayTasks.filter { !$0.completed }.count
            
            // Post notification for profile view update
            NotificationCenter.default.post(
                name: .tasksUpdated,
                object: nil,
                userInfo: [
                    "taskDone": taskDoneCount,
                    "taskLeft": taskLeftCount
                ]
            )
        }
    
    func addTask(title: String, description: String, date: Date?, category: TaskCategory? = nil, priority: TaskPriority? = nil) {
        let newItem = Item(context: context)
        newItem.title = title
        newItem.taskDescription = description
        newItem.date = date ?? Date()
        newItem.id = UUID()
        newItem.completed = false
        newItem.category = category?.rawValue
        newItem.priority = Int16(priority?.rawValue ?? 0)
        
        saveContext()
    }

    
    func deleteSingleTask(_ item: Item) {
        context.delete(item)
        saveContext()
    }
    
    func editTask(item: Item, newTitle: String, newDescription: String, category: TaskCategory? = nil, priority: TaskPriority? = nil) {
        item.title = newTitle
        item.taskDescription = newDescription
        if let category = category {
            item.category = category.rawValue
        }
        if let priority = priority {
            item.priority = Int16(priority.rawValue)
        }
        saveContext()
    }
    
    func toggleTaskCompletion(_ item: Item) {
        item.completed.toggle()
        saveContext()
        fetchItems()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchItems()  // Refresh the list after saving
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
    static let profileUpdated = Notification.Name("profileUpdated")
}


