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
                        onAddTask: { showingSheet = true }
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

    private func taskListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Today Section
                if !viewModel.newItems.isEmpty {
                    taskSection(
                        title: "Today",
                        isExpanded: $viewModel.isTodayExpanded,
                        items: viewModel.newItems
                    )
                }

                // Completed Section
                if !viewModel.completedTasks.isEmpty {
                    taskSection(
                        title: "Completed",
                        isExpanded: $viewModel.isCompletedExpanded,
                        items: viewModel.completedTasks
                    )
                }
            }
            .padding(.vertical)
        }
    }

    private func taskSection(title: String, isExpanded: Binding<Bool>, items: [Item]) -> some View {
        Section(header: TaskHeaderView(title: title, isExpanded: isExpanded)) {
            if isExpanded.wrappedValue {
                VStack(spacing: 10) {
                    ForEach(items) { item in
                        TaskRow(
                            item: item,
                            onDelete: { showDeleteAlert(for: item) },
                            onEdit: { editedItem, newTitle, newDescription in
                                viewModel.editTask(item: editedItem, newTitle: newTitle, newDescription: newDescription)
                            },
                            onComplete: { item in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.toggleTaskCompletion(item)
                                }
                            }
                        )
                        .transition(.opacity)
                    }
                }
                .padding(.top, 10)
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

struct TaskHeaderView: View {
    let title: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
         
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

struct TaskRow: View {
    let item: Item
    var onDelete: () -> Void
    var onEdit: (Item, String, String) -> Void
    var onComplete: (Item) -> Void

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
                if isDescriptionVisible, let description = item.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
            Spacer()
            Button(action: {
                onComplete(item)
            }) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation {
                isDescriptionVisible.toggle()
            }
        }
        .contextMenu {
            Button(action: {
                editedTitle = item.title ?? ""
                editedDescription = item.taskDescription ?? ""
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
