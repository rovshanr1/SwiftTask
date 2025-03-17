import SwiftUI

struct GuestView: View {
    @State private var tasks: [TaskItem] = []  
    @State private var showingSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: TaskItem?
    @State private var navigateToProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    taskListView()
                    Spacer()
                    TabBarView(
                        navigateToHome: .constant(false),
                        navigateToProfile: $navigateToProfile,
                        onAddTask: { showingSheet = true }
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showingSheet) {
                AddTaskSheet(
                    isPresented: $showingSheet,
                    title: $newTaskTitle,
                    description: $newTaskDescription,
                    onSave: saveTask
                )
            }
            .alert("Are you sure?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        tasks.removeAll { $0.id == item.id }
                        itemToDelete = nil
                    }
                }
            }
//            .navigationDestination(isPresented: $navigateToProfile) {
//                ProfileView(homeViewModel: viewModel)
//            }
        }
    }

    private func taskListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if tasks.isEmpty {
                    EmptyTaskView()
                } else {
                    ForEach(tasks) { item in
                        GuestTaskRow(
                            item: item,
                            onDelete: { showDeleteAlert(for: item) },
                            onEdit: { editedItem, newTitle, newDescription in
                                if let index = tasks.firstIndex(where: { $0.id == editedItem.id }) {
                                    tasks[index].title = newTitle
                                    tasks[index].description = newDescription
                                }
                            },
                            onComplete: { item in
                                if let index = tasks.firstIndex(where: { $0.id == item.id }) {
                                    tasks[index].completed.toggle()
                                }
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }

    private func saveTask() {
        if !newTaskTitle.isEmpty {
            let newTask = TaskItem(title: newTaskTitle, description: newTaskDescription)
            tasks.append(newTask)
            newTaskTitle = ""
            newTaskDescription = ""
        }
    }
    
    private func showDeleteAlert(for item: TaskItem) {
        itemToDelete = item
        showingDeleteAlert = true
    }
}

struct GuestTaskRow: View {
    let item: TaskItem
    var onDelete: () -> Void
    var onEdit: (TaskItem, String, String) -> Void
    var onComplete: (TaskItem) -> Void

    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: { onComplete(item) }) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .onTapGesture {
            isEditing.toggle()
        }
        .contextMenu {
            Button(action: {
                editedTitle = item.title
                editedDescription = item.description
                isEditing = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $isEditing) {
            EditTaskSheet(
                isPresented: $isEditing,
                title: $editedTitle,
                description: $editedDescription,
                onSave: {
                    onEdit(item, editedTitle, editedDescription)
                    isEditing = false
                }
            )
        }
    }
}

// Basit bir geçici görev modeli
struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var completed: Bool = false
}
