//
//  CalendarView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    @State private var navigateToFocus = false
    @State private var navigateToCalendar = true
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(context: context))
    }
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Calendar")
                    .font(.title)
                    .foregroundStyle(themeManager.currentTheme.text)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Category Selector with Gradient Background
                CategorySelectorView(
                    selectedCategory: $viewModel.selectedCategory,
                    categories: TaskCategory.allCases,
                    theme: themeManager.currentTheme
                )
                .padding(.vertical, 8)
                
                // Week View with Animation
                WeekView(
                    selectedDate: Binding(
                        get: { viewModel.selectedDate },
                        set: { viewModel.setSelectedDate($0) }
                    ),
                    daysInWeek: viewModel.getDaysInWeek(),
                    hasCompletedTasks: viewModel.hasCompletedTasks,
                    totalTasks: viewModel.totalTasks,
                    theme: themeManager.currentTheme
                )
                .padding(.vertical)
                
                // Selected Date Header
                Text(viewModel.formattedDate(viewModel.selectedDate))
                    .font(.headline)
                    .foregroundStyle(themeManager.currentTheme.text)
                    .padding(.vertical, 8)
                
                // Tasks List with Empty State
                TaskListView(
                    tasks: viewModel.tasksForDate(viewModel.selectedDate),
                    onComplete: viewModel.toggleTaskCompletion,
                    theme: themeManager.currentTheme
                )
                
                Spacer()
                
                // Tab Bar
                TabBarView(
                    navigateToHome: $navigateToHome,
                    navigateToProfile: $navigateToProfile,
                    navigateToCalendar: .constant(true),
                    navigateToFocus: $navigateToFocus,
                    onAddTask: {}
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView(context: PersistenceController.shared.viewContext)
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(homeViewModel: HomeViewModel(context: PersistenceController.shared.viewContext))
        }
        .navigationDestination(isPresented: $navigateToFocus) {
            FocusView()
        }
    }
}

// MARK: - Supporting Views

struct CategorySelectorView: View {
    @Binding var selectedCategory: TaskCategory
    let categories: [TaskCategory]
    let theme: ThemeColors
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        color: category.color,
                        icon: category.icon
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(theme.background)
    }
}

struct WeekView: View {
    @Binding var selectedDate: Date
    let daysInWeek: [Date]
    let hasCompletedTasks: (Date) -> Bool
    let totalTasks: (Date) -> Int
    let theme: ThemeColors
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(daysInWeek, id: \.self) { date in
                    DayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasCompletedTasks: hasCompletedTasks(date),
                        totalTasks: totalTasks(date),
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDate = date
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let hasCompletedTasks: Bool
    let totalTasks: Int
    let theme: ThemeColors
    let onTap: () -> Void
    
    private static let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(Self.weekDayFormatter.string(from: date).uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? theme.text : theme.secondaryText)
            
            Text(Self.dayFormatter.string(from: date))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? theme.text : theme.secondaryText)
            
            if totalTasks > 0 {
                HStack(spacing: 4) {
                    if hasCompletedTasks {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Text("\(totalTasks)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(hasCompletedTasks ? .green : theme.secondaryText)
                }
            }
        }
        .frame(width: 50, height: 85)
        .background(isSelected ? theme.accent.opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? theme.accent : Color.clear, lineWidth: 1.5)
        )
        .onTapGesture(perform: onTap)
    }
}

struct TaskListView: View {
    let tasks: [Item]
    let onComplete: (Item) -> Void
    let theme: ThemeColors
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                if tasks.isEmpty {
                    EmptyTasksView(theme: theme)
                } else {
                    ForEach(tasks) { task in
                        TaskCardView(task: task, onComplete: onComplete, theme: theme)
                            .transition(.opacity)
                    }
                }
            }
            .padding()
        }
    }
}

struct EmptyTasksView: View {
    let theme: ThemeColors
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundStyle(theme.secondaryText)
            Text("No tasks scheduled for this day")
                .font(.headline)
                .foregroundStyle(theme.secondaryText)
            Text("Tap + to add a new task")
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

struct TaskCardView: View {
    let task: Item
    let onComplete: (Item) -> Void
    let theme: ThemeColors
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title ?? "Unnamed Task")
                    .font(.headline)
                    .foregroundStyle(theme.text)
                
                if let description = task.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                        .lineLimit(2)
                }
                
                if let date = task.date {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(formatTime(date))
                            .font(.caption)
                    }
                    .foregroundStyle(theme.secondaryText)
                }
            }
            
            Spacer()
            
            Button(action: { onComplete(task) }) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .foregroundColor(task.completed ? .green : theme.secondaryText)
                    
                    if task.completed {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(theme.secondaryBackground)
        .cornerRadius(12)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


