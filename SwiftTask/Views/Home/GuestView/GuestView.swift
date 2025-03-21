import SwiftUI

struct GuestView: View {
    @StateObject private var viewModel = GuestViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    taskListView()
                    Spacer()
                    GuestTabBarView(onAddTask: { viewModel.showingSheet = true })
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $viewModel.showingSheet) {
                GuestAddTaskSheet(
                    isPresented: $viewModel.showingSheet,
                    title: $viewModel.newTaskTitle,
                    description: $viewModel.newTaskDescription,
                    onSave: viewModel.addTask
                )
            }
            .alert("Are you sure?", isPresented: $viewModel.showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let item = viewModel.itemToDelete {
                        viewModel.deleteTask(item: item)
                    }
                }
            }
            .alert("Login Required", isPresented: $viewModel.showingLoginPrompt) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please create an account or login to access all features.")
            }
        }
    }

    private func taskListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.tasks.isEmpty {
                    EmptyTaskView()
                } else {
                    ForEach(viewModel.tasks) { item in
                        GuestTaskRow(
                            item: item,
                            onDelete: { viewModel.showDeleteAlert(for: item) },
                            onEdit: { editedItem, newTitle, newDescription in
                                viewModel.editTask(item: editedItem, newTitle: newTitle, newDescription: newDescription)
                            },
                            onComplete: { item in
                                viewModel.toggleTaskCompletion(item: item)
                            }
                        )
                    }
                }
            }
            .padding()
        }
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

