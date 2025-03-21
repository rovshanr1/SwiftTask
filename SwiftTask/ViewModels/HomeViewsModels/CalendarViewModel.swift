//
//  CalendarViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 11.02.25.
//

import Foundation
import SwiftUI
import CoreData

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var tasks: [Item] = []
    @Published var selectedCategory: TaskCategory = .all
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTasks()
        
        // Görev güncellemelerini dinle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksUpdated),
            name: .tasksUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func tasksUpdated() {
        DispatchQueue.main.async {
            self.fetchTasks()
            self.objectWillChange.send()
        }
    }
    
    func fetchTasks() {
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    func tasksForDate(_ date: Date) -> [Item] {
        let filteredTasks = tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return Calendar.current.isDate(taskDate, inSameDayAs: date)
        }
        
        if selectedCategory == .all {
            return filteredTasks
        } else {
            return filteredTasks.filter { task in
                task.category == selectedCategory.rawValue
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
    }
    
    func weekDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func getDaysInWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekDay = calendar.component(.weekday, from: today)
        let weekDays = (1...7).map { day -> Date in
            calendar.date(byAdding: .day, value: day - weekDay, to: today) ?? today
        }
        return weekDays
    }
}
