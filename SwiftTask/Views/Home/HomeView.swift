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
    @State private var navigateToCalendar = false
    @State private var navigateToHome = true
    @State private var navigateToFocus = false
    
    
    

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    if navigateToHome {
                        VStack(spacing: 16) {
                            headerView
                            searchBar
                            taskListView()
                                .padding(.bottom, 90)
                        }
                    } else if navigateToFocus {
                        FocusView()
                            .padding(.bottom, 90)
                    }
                }
                
                VStack {
                    Spacer()
                    TabBarView(
                        navigateToHome: .constant(true),
                        navigateToProfile: $navigateToProfile,
                        navigateToCalendar: $navigateToCalendar,
                        navigateToFocus: $navigateToFocus,
                        onAddTask: { showingSheet = true }
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear { viewModel.fetchItems() }
            .onTapGesture {
                hideKeyboard()
            }
            .sheet(isPresented: $showingSheet) {
                ZStack{
                    Color(red: 0.07, green: 0.07, blue: 0.07)
                        .ignoresSafeArea()
                    
                    AddTaskSheet(
                        isPresented: $showingSheet,
                        title: $newTaskTitle,
                        description: $newTaskDescription,
                        selectedCategory: $viewModel.selectedCategory,
                        selectedPriority: $viewModel.selectedPriority,
                        onSave: {
                            if !newTaskTitle.isEmpty {
                                viewModel.addTask(
                                    title: newTaskTitle,
                                    description: newTaskDescription,
                                    date: newDate,
                                    category: viewModel.selectedCategory,
                                    priority: viewModel.selectedPriority
                                )
                                newTaskTitle = ""
                                newTaskDescription = ""
                                newDate = Date()
                                viewModel.selectedCategory = nil
                                viewModel.selectedPriority = nil
                            }
                        }
                    )
                }
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
                ProfileView(homeViewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToCalendar){
                CalendarView(context: PersistenceController.shared.viewContext)
            }
            .navigationDestination(isPresented: $navigateToFocus) {
                FocusView()
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hello,")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text(viewModel.userName)
                    .font(.title)
                    .foregroundColor(.white)
            }
            Spacer()
            
            NavigationLink(destination: ProfileView(homeViewModel: viewModel)) {
                if let imageData = viewModel.profileImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for your tasks...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .onChange(of: viewModel.searchText) { oldValue, newValue in
                        viewModel.isSearching = !viewModel.searchText.isEmpty
                    }
                    .submitLabel(.search)
                    .onSubmit {
                        hideKeyboard()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        viewModel.isSearching = false
                        hideKeyboard()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(red: 0.21, green: 0.21, blue: 0.21))
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func taskListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.filteredNewItems.isEmpty && viewModel.filteredCompletedTasks.isEmpty {
                    if viewModel.isSearching {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No matching tasks found")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
                        EmptyTaskView()
                    }
                } else {
                    if !viewModel.filteredNewItems.isEmpty {
                        taskSection(
                            title: "New Task",
                            isExpanded: $viewModel.isTodayExpanded,
                            items: viewModel.filteredNewItems
                        )
                    }

                    if !viewModel.filteredCompletedTasks.isEmpty {
                        taskSection(
                            title: "Completed",
                            isExpanded: $viewModel.isCompletedExpanded,
                            items: viewModel.filteredCompletedTasks
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
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
                            onEdit: { editedItem, newTitle, newDescription, newCategory, newPriority in
                                viewModel.editTask(
                                    item: editedItem,
                                    newTitle: newTitle,
                                    newDescription: newDescription,
                                    category: newCategory,
                                    priority: newPriority
                                )
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
            print("Saving task: \(newTaskTitle)")
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
    var onEdit: (Item, String, String, TaskCategory?, TaskPriority?) -> Void
    var onComplete: (Item) -> Void

    @State private var isDescriptionVisible = false
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    @State private var selectedCategory: TaskCategory?
    @State private var selectedPriority: TaskPriority?
    
    private var taskCategory: TaskCategory? {
        if let categoryString = item.category {
            return TaskCategory(rawValue: categoryString)
        }
        return nil
    }
    
    private var taskPriority: TaskPriority? {
        let priorityValue = Int(item.priority)
        if priorityValue > 0 {
            return TaskPriority(rawValue: priorityValue)
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title ?? "Unnamed Task")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let category = taskCategory {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .foregroundColor(category.color)
                            Text(category.rawValue)
                                .font(.caption)
                                .foregroundColor(category.color)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(category.color.opacity(0.2))
                        .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                if let priority = taskPriority {
                    Text(priority.title)
                        .font(.caption)
                        .foregroundColor(priority.color)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(priority.color.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Button(action: {
                    onComplete(item)
                }) {
                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.white)
                }
            }
            
            if isDescriptionVisible, let description = item.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .transition(.opacity)
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
                selectedCategory = taskCategory
                selectedPriority = taskPriority
                isEditing = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $isEditing) {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                
                EditTaskSheet(
                    isPresented: $isEditing,
                    title: $editedTitle,
                    description: $editedDescription,
                    selectedCategory: $selectedCategory,
                    selectedPriority: $selectedPriority,
                    onSave: {
                        onEdit(item, editedTitle, editedDescription, selectedCategory, selectedPriority)
                        isEditing = false
                    }
                )
            }
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

