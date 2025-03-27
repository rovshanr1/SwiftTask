import SwiftUI
import UserNotifications

struct AddTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    @Binding var selectedCategory: TaskCategory?
    @Binding var selectedPriority: TaskPriority?
    @State private var showAllCategories = false
    @State private var enableReminder = false
    @State private var reminderDate = Date()
    @StateObject private var themeManager = ThemeManager.shared
    var onSave: () -> Void
    
    private let mainCategories: [TaskCategory] = [.work, .personal, .home]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Add Task")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(themeManager.currentTheme.text)
                
                Divider()
                    .background(themeManager.currentTheme.secondaryText.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Input Fields
                    VStack(spacing: 16) {
                        InputField(
                            title: "Task Title",
                            text: $title,
                            placeholder: "Enter task title"
                        )
                        
                        InputField(
                            title: "Description",
                            text: $description,
                            placeholder: "Enter task description"
                        )
                    }
                    
                    // Categories
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Category")
                                .foregroundStyle(themeManager.currentTheme.text)
                                .font(.headline)
                            Spacer()
                            Button(action: { showAllCategories.toggle() }) {
                                HStack(spacing: 4) {
                                    Text(showAllCategories ? "Show Less" : "Show More")
                                        .font(.system(size: 14))
                                        .foregroundStyle(themeManager.currentTheme.accent)
                                    Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
                                        .foregroundStyle(themeManager.currentTheme.accent)
                                }
                            }
                        }
                        
                        if !showAllCategories {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(mainCategories, id: \.self) { category in
                                    ModernCategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    if category != .all {
                                        ModernCategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            action: { selectedCategory = category }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Priority")
                            .foregroundStyle(themeManager.currentTheme.text)
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                ModernPriorityButton(
                                    priority: priority,
                                    isSelected: selectedPriority == priority,
                                    action: { selectedPriority = priority }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Reminder Section
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $enableReminder) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(themeManager.currentTheme.accent)
                                Text("Set Reminder")
                                    .foregroundStyle(themeManager.currentTheme.text)
                                    .font(.headline)
                            }
                        }
                        .tint(themeManager.currentTheme.accent)
                        
                        if enableReminder {
                            DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .colorScheme(.dark)
                                .tint(themeManager.currentTheme.accent)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.top, 8)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeManager.currentTheme.secondaryBackground)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    if enableReminder {
                        checkAndScheduleNotification()
                    }
                    onSave()
                    isPresented = false
                }) {
                    Text("Create")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeManager.currentTheme.accent)
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
        .presentationDetents([.large])
    }
    
    private func checkAndScheduleNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                print("Reminder scheduled for: \(reminderDate)")
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        print("Notification permission granted")
                    } else if let error = error {
                        print("Notification permission error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}



