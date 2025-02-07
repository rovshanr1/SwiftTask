import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showingSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newDate = Date()
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: Item?
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    taskListView()
                    Spacer()
                    TabBarView(
                        navigateToHome: .constant(false),
                        navigateToProfile: $navigateToProfile,
                        onAddTask: {showingSheet = true}
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear { viewModel.fetchItems() }
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
                        viewModel.deleteSingleTask(item)
                        itemToDelete = nil
                    }
                }
            } message: {
                Text("This task will be permanently deleted.")
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                           ProfileView()
                       }
        }
    }

    
    @ViewBuilder
    private func taskListView() -> some View {
        ScrollView {
            if viewModel.items.isEmpty {
                EmptyTaskView()
            } else {
                VStack {
                    ForEach(viewModel.items) { item in
                        TaskRow(
                            item: item,
                            onDelete: { showDeleteAlert(for: item) },
                            onEdit: { editedItem, newTitle, newDescription in
                                viewModel.editTask(item: editedItem, newTitle: newTitle, newDescription: newDescription)
                            }
                        )
                    }
                }
            }
        }
    }
    
    private func saveTask() {
        if !newTaskTitle.isEmpty {
            viewModel.addTask(title: newTaskTitle, description: newTaskDescription, date: newDate)
            newTaskTitle = ""
            newTaskDescription = ""
            newDate = Date()
        }
    }
    
    private func showDeleteAlert(for item: Item) {
        itemToDelete = item
        showingDeleteAlert = true
    }

}

struct TaskRow: View {
    let item: Item
    var onDelete: () -> Void
    var onEdit: (Item, String, String) -> Void
    
    @State private var isDescriptionVisible = false
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title ?? "Unnamed Task")
                    .font(.headline)
                    .foregroundColor(.white)
                if let date = item.date {
                    Text(formattedDate(date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                if isDescriptionVisible, let description = item.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: {
                // Switch to edit mode
                editedTitle = item.title ?? ""
                editedDescription = item.taskDescription ?? ""
                isEditing = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
        }
        .onTapGesture {
            withAnimation {
                isDescriptionVisible.toggle()
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

private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy"
    return formatter.string(from: date)
}

struct EmptyTaskView: View {
    var body: some View {
        VStack {
            Image("Checklist-rafiki 1")
                .resizable()
                .scaledToFit()
                .padding()
            VStack(spacing: 10) {
                Text("What do you want to do today?")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                Text("Tap + to add your tasks")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

#Preview {
    HomeView(context: PersistenceController.shared.viewContext)
}
