//
//  CalendarViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 11.02.25.
//

import Foundation
import SwiftUI
import CoreData

struct CalendarHelper {
    static let shared = CalendarHelper()
    private let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter
    }()
    
    func weekDay(_ date: Date) -> String {
        weekDayFormatter.string(from: date)
    }
    
    func dayNumber(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }
    
    func formattedDate(_ date: Date) -> String {
        fullDateFormatter.string(from: date)
    }
}

@MainActor
class CalendarViewModel: NSObject, ObservableObject {
    @Published private(set) var selectedDate = Date()
    @Published private(set) var tasks: [Item] = []
    @Published var selectedCategory: TaskCategory = .all {
        didSet {
            updateFilteredTasks()
        }
    }
    
    private let context: NSManagedObjectContext
    private var cachedTasks: [String: [Item]] = [:]
    private var filteredTasks: [String: [Item]] = [:]
    private let calendar = Calendar.current
    private let isTestEnvironment: Bool
    private var daysInWeek: [Date] = []
    private var taskCountCache: [String: (total: Int, completed: Int)] = [:]
    
    private lazy var fetchRequest: NSFetchRequest<Item> = {
        let request = NSFetchRequest<Item>(entityName: "Item")
        let startDate = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: Date()))!
        let endDate = calendar.date(byAdding: .day, value: 3, to: calendar.startOfDay(for: Date()))!
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return request
    }()
    
    init(context: NSManagedObjectContext, isTestEnvironment: Bool = false) {
        self.context = context
        self.isTestEnvironment = isTestEnvironment
        super.init()
        
        Task { @MainActor in
            await setupInitialData()
        }
        
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
    
    private func setupInitialData() async {
        daysInWeek = calculateDaysInWeek()
        await fetchTasks()
    }
    
    @objc private func tasksUpdated() {
        Task { @MainActor in
            await fetchTasks()
        }
    }
    
    private func fetchTasks() async {
        do {
            let fetchedTasks = try context.fetch(fetchRequest)
            tasks = fetchedTasks
            updateCaches()
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    private func updateCaches() {
        cachedTasks.removeAll()
        filteredTasks.removeAll()
        taskCountCache.removeAll()
        
        // Günlük görevleri önbelleğe al
        for date in daysInWeek {
            let dateKey = dateToString(date)
            let tasksForDate = getTasksForDate(date)
            cachedTasks[dateKey] = tasksForDate
            updateFilteredTasksForDate(date, tasks: tasksForDate)
            updateTaskCountForDate(date, tasks: tasksForDate)
        }
    }
    
    private func updateFilteredTasks() {
        for date in daysInWeek {
            if let tasks = cachedTasks[dateToString(date)] {
                updateFilteredTasksForDate(date, tasks: tasks)
            }
        }
        objectWillChange.send()
    }
    
    private func updateFilteredTasksForDate(_ date: Date, tasks: [Item]) {
        let dateKey = dateToString(date)
        if selectedCategory == .all {
            filteredTasks[dateKey] = tasks
        } else {
            filteredTasks[dateKey] = tasks.filter { $0.category == selectedCategory.rawValue }
        }
        updateTaskCountForDate(date, tasks: filteredTasks[dateKey] ?? [])
    }
    
    private func updateTaskCountForDate(_ date: Date, tasks: [Item]) {
        let dateKey = dateToString(date)
        let completedCount = tasks.filter { $0.completed }.count
        taskCountCache[dateKey] = (total: tasks.count, completed: completedCount)
    }
    
    private func getTasksForDate(_ date: Date) -> [Item] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return taskDate >= startOfDay && taskDate < endOfDay
        }
    }
    
    func tasksForDate(_ date: Date) -> [Item] {
        let dateKey = dateToString(date)
        return filteredTasks[dateKey] ?? []
    }
    
    func hasCompletedTasks(for date: Date) -> Bool {
        let dateKey = dateToString(date)
        return taskCountCache[dateKey]?.completed ?? 0 > 0
    }
    
    func totalTasks(for date: Date) -> Int {
        let dateKey = dateToString(date)
        return taskCountCache[dateKey]?.total ?? 0
    }
    
    func toggleTaskCompletion(_ task: Item) {
        task.completed.toggle()
        
        do {
            try context.save()
            updateCaches()
            NotificationCenter.default.post(name: .tasksUpdated, object: nil)
        } catch {
            print("Error saving context: \(error)")
            task.completed.toggle() // Hata durumunda geri al
        }
    }
    
    func setSelectedDate(_ date: Date) {
        selectedDate = date
    }
    
    func formattedDate(_ date: Date) -> String {
        CalendarHelper.shared.formattedDate(date)
    }
    
    private func calculateDaysInWeek() -> [Date] {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -3, to: today) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startDate)
        }
    }
    
    func getDaysInWeek() -> [Date] {
        daysInWeek
    }
    
    private func dateToString(_ date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}

extension Notification.Name {
    static let calendarTasksUpdated = Notification.Name("calendarTasksUpdated")
}
