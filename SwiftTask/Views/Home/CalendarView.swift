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
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    @State private var navigateToFocus = false
    @State private var navigateToCalendar = true
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(context: context))
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                CalendarHeaderView(title: "Calendar")
                
                // Category Selector with Gradient Background
                CategorySelectorView(
                    selectedCategory: $viewModel.selectedCategory,
                    categories: TaskCategory.allCases
                )
                .padding(.vertical, 8)
                
                // Week View with Animation
                WeekView(
                    selectedDate: $viewModel.selectedDate,
                    daysInWeek: viewModel.getDaysInWeek(),
                    hasCompletedTasks: viewModel.hasCompletedTasks,
                    totalTasks: viewModel.totalTasks
                )
                .padding(.vertical)
                
                // Selected Date Header
                Text(viewModel.formattedDate(viewModel.selectedDate))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                
                // Tasks List with Empty State
                TaskListView(
                    tasks: viewModel.tasksForDate(viewModel.selectedDate),
                    onComplete: viewModel.toggleTaskCompletion
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

struct CalendarHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
}

struct CategorySelectorView: View {
    @Binding var selectedCategory: TaskCategory
    let categories: [TaskCategory]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.07, green: 0.07, blue: 0.07),
                    Color(red: 0.07, green: 0.07, blue: 0.07).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct WeekView: View {
    @Binding var selectedDate: Date
    let daysInWeek: [Date]
    let hasCompletedTasks: (Date) -> Bool
    let totalTasks: (Date) -> Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(daysInWeek, id: \.self) { date in
                    DayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasCompletedTasks: hasCompletedTasks(date),
                        totalTasks: totalTasks(date)
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
                .foregroundColor(isSelected ? .white : .gray)
            
            Text(Self.dayFormatter.string(from: date))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .gray)
            
            if totalTasks > 0 {
                HStack(spacing: 4) {
                    if hasCompletedTasks {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Text("\(totalTasks)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(hasCompletedTasks ? .green : .gray)
                }
            }
        }
        .frame(width: 50, height: 85)
        .background(isSelected ? Color.orange.opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1.5)
        )
        .onTapGesture(perform: onTap)
    }
}

struct TaskListView: View {
    let tasks: [Item]
    let onComplete: (Item) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                if tasks.isEmpty {
                    EmptyTasksView()
                } else {
                    ForEach(tasks) { task in
                        TaskCardView(task: task, onComplete: onComplete)
                            .transition(.opacity)
                    }
                }
            }
            .padding()
        }
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No tasks scheduled for this day")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tap + to add a new task")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

struct TaskCardView: View {
    let task: Item
    let onComplete: (Item) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title ?? "Unnamed Task")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let description = task.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                if let date = task.date {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(formatTime(date))
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: { onComplete(task) }) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .foregroundColor(task.completed ? .green : .gray)
                    
                    if task.completed {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


