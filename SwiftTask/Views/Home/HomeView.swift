import SwiftUI
import CoreData
import UserNotifications

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var themeManager = ThemeManager.shared
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
    @State private var keyboardHeight: CGFloat = 0
    
    
    

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if navigateToHome {
                        VStack{
                            headerView
                        }
                        .padding(.bottom)
                                  
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {
                                taskSummaryView
                                searchBar
                                taskListView()
                            }
                            .padding(.bottom, 90)
                        }
                        .scrollDismissesKeyboard(.immediately)
                        .overlay {
                            if viewModel.isLoading {
                                LoadingView()
                            }
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
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear { viewModel.fetchItems() }
            .onTapGesture { hideKeyboard() }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showingSheet) {
                AddTaskSheetContainer(
                    isPresented: $showingSheet,
                    title: $newTaskTitle,
                    description: $newTaskDescription,
                    selectedCategory: $viewModel.selectedCategory,
                    selectedPriority: $viewModel.selectedPriority,
                    onSave: saveNewTask
                )
            }
            .alert("Are you sure you want to delete this task?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        viewModel.deleteSingleTask(item)
                        itemToDelete = nil
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                ProfileView(homeViewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToCalendar) {
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
                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                Text(viewModel.userName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(themeManager.currentTheme.text)
            }
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        DispatchQueue.main.async {
                            if settings.authorizationStatus == .denied {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } else {
                                navigateToProfile = true
                            }
                        }
                    }
                }) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(themeManager.currentTheme.accent)
                }
                
                NavigationLink(destination: ProfileView(homeViewModel: viewModel)) {
                    ProfileImageView(imageData: viewModel.profileImageData)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private var taskSummaryView: some View {
        HStack(spacing: 16) {
            TaskSummaryCard(
                title: "Completed",
                count: viewModel.taskDoneCount,
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            TaskSummaryCard(
                title: "Remaining",
                count: viewModel.taskLeftCount,
                icon: "clock.fill",
                color: themeManager.currentTheme.accent
            )
        }
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                TextField("Search your tasks...", text: $viewModel.searchText)
                    .foregroundStyle(themeManager.currentTheme.text)
                    .tint(themeManager.currentTheme.text)
                    .onChange(of: viewModel.searchText) { oldValue, newValue in
                        viewModel.isSearching = !viewModel.searchText.isEmpty
                    }
                    .submitLabel(.search)
                    .onSubmit { hideKeyboard() }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        viewModel.isSearching = false
                        hideKeyboard()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(themeManager.currentTheme.secondaryText)
                    }
                }
            }
            .padding(12)
            .background(themeManager.currentTheme.secondaryBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private func taskListView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if viewModel.filteredNewItems.isEmpty && viewModel.filteredCompletedTasks.isEmpty {
                if viewModel.isSearching {
                    EmptySearchView()
                } else {
                    EmptyTaskView()
                }
            } else {
                if !viewModel.filteredNewItems.isEmpty {
                    TaskSectionView(
                        title: "New Tasks",
                        isExpanded: $viewModel.isTodayExpanded,
                        items: viewModel.filteredNewItems,
                        onDelete: showDeleteAlert,
                        onEdit: viewModel.editTask,
                        onComplete: viewModel.toggleTaskCompletion
                    )
                }

                if !viewModel.filteredCompletedTasks.isEmpty {
                    TaskSectionView(
                        title: "Completed",
                        isExpanded: $viewModel.isCompletedExpanded,
                        items: viewModel.filteredCompletedTasks,
                        onDelete: showDeleteAlert,
                        onEdit: viewModel.editTask,
                        onComplete: viewModel.toggleTaskCompletion
                    )
                }
            }
        }
        .padding(.vertical)
    }

    private func saveNewTask() {
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

    private func showDeleteAlert(for item: Item) {
        itemToDelete = item
        showingDeleteAlert = true
    }
}







struct TaskSectionView: View {
    let title: String
    @Binding var isExpanded: Bool
    let items: [Item]
    let onDelete: (Item) -> Void
    let onEdit: (Item, String, String, TaskCategory?, TaskPriority?) -> Void
    let onComplete: (Item) -> Void
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation { isExpanded.toggle() }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(themeManager.currentTheme.text)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundStyle(themeManager.currentTheme.secondaryText)
                }
                .padding(.horizontal)
            }
            
            if isExpanded {
                LazyVStack(spacing: 12) {
                    ForEach(items) { item in
                        TaskRow(
                            item: item,
                            onDelete: { onDelete(item) },
                            onEdit: onEdit,
                            onComplete: onComplete
                        )
                        .transition(.opacity)
                    }
                }
            }
        }
    }
}

struct AddTaskSheetContainer: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    @Binding var selectedCategory: TaskCategory?
    @Binding var selectedPriority: TaskPriority?
    let onSave: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.background
                .ignoresSafeArea()
            
            AddTaskSheet(
                isPresented: $isPresented,
                title: $title,
                description: $description,
                selectedCategory: $selectedCategory,
                selectedPriority: $selectedPriority,
                onSave: onSave
            )
        }
    }
}

struct TaskHeaderView: View {
    let title: String
    @Binding var isExpanded: Bool
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(themeManager.currentTheme.text)
         
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .foregroundStyle(themeManager.currentTheme.secondaryText)
        }
        .padding()
        .background(themeManager.currentTheme.secondaryBackground.opacity(0.2))
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
    @StateObject private var themeManager = ThemeManager.shared

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
                        .foregroundStyle(themeManager.currentTheme.text)
                    
                    if let category = taskCategory {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .foregroundStyle(category.color)
                            Text(category.rawValue)
                                .font(.caption)
                                .foregroundStyle(category.color)
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
                        .foregroundStyle(priority.color)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(priority.color.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Button(action: {
                    print("Task completion toggled - Current state: \(item.completed)")
                    withAnimation(.spring()) {
                        onComplete(item)
                    }
                }) {
                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.completed ? .green : themeManager.currentTheme.text)
                        .font(.system(size: 24))
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if isDescriptionVisible, let description = item.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(themeManager.currentTheme.secondaryBackground)
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
                themeManager.currentTheme.background
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


