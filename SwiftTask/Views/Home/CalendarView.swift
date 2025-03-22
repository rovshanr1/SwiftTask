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
            
            VStack() {
                Text("Calendar")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category,
                                color: category.color,
                                icon: category.icon,
                                action: {
                                    withAnimation {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Week Days View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.getDaysInWeek(), id: \.self) { date in
                            DayView(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                            )
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedDate = date
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Tasks List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.tasksForDate(viewModel.selectedDate)) { task in
                            TaskCardView(task: task)
                        }
                        
                        if viewModel.tasksForDate(viewModel.selectedDate).isEmpty {
                            Text("No tasks for this day")
                                .foregroundColor(.gray)
                                .padding(.top, 30)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                TabBarView(
                    navigateToHome: $navigateToHome,
                    navigateToProfile: $navigateToProfile,
                    navigateToCalendar: .constant(true),
                    navigateToFocus: $navigateToFocus,
                    onAddTask: { /* Calendar does not support adding tasks */ }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView(context: PersistenceController.shared.viewContext)
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(homeViewModel: HomeViewModel(context: PersistenceController.shared.viewContext))
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $navigateToFocus) {
            FocusView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    @StateObject private var viewModel = CalendarViewModel(context: PersistenceController.shared.viewContext)
    
    var body: some View {
        VStack(spacing: 8) {
            Text(viewModel.weekDay(date).uppercased())
                .font(.caption)
                .foregroundColor(isSelected ? .white : .gray)
            
            Text(viewModel.dayNumber(date))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .gray)
        }
        .frame(width: 45, height: 80)
        .background(isSelected ? Color.purple.opacity(0.3) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1)
        )
    }
}

struct TaskCardView: View {
    let task: Item
    
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
                }
                
                if let date = task.date {
                    Text(formatTime(date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Circle()
                .stroke(lineWidth: 1.5)
                .frame(width: 20, height: 20)
                .foregroundColor(task.completed ? .green : .gray)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(task.completed ? .green : .clear)
                )
        }
        .padding()
        .background(Color(red: 0.21, green: 0.21, blue: 0.21).opacity(0.3))
        .cornerRadius(10)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView(context: PersistenceController.shared.viewContext)
}
