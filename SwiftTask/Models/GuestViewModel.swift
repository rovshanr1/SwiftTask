import Foundation

class GuestViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var showingSheet = false
    @Published var showingDeleteAlert = false
    @Published var showingLoginPrompt = false
    @Published var newTaskTitle = ""
    @Published var newTaskDescription = ""
    @Published var itemToDelete: TaskItem?
    
    func addTask() {
        if !newTaskTitle.isEmpty {
            let newTask = TaskItem(title: newTaskTitle, description: newTaskDescription)
            tasks.append(newTask)
            resetNewTaskFields()
        }
    }
    
    func deleteTask(item: TaskItem) {
        tasks.removeAll { $0.id == item.id }
        itemToDelete = nil
    }
    
    func editTask(item: TaskItem, newTitle: String, newDescription: String) {
        if let index = tasks.firstIndex(where: { $0.id == item.id }) {
            tasks[index].title = newTitle
            tasks[index].description = newDescription
        }
    }
    
    func toggleTaskCompletion(item: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == item.id }) {
            tasks[index].completed.toggle()
        }
    }
    
    func showDeleteAlert(for item: TaskItem) {
        itemToDelete = item
        showingDeleteAlert = true
    }
    
    private func resetNewTaskFields() {
        newTaskTitle = ""
        newTaskDescription = ""
    }
} 