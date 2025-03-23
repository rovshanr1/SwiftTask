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
    static func weekDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    static func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
    }
}

class CalendarViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var selectedDate = Date()
    @Published var tasks: [Item] = []
    @Published var selectedCategory: TaskCategory = .all
    private let context: NSManagedObjectContext
    private var cachedTasks: [Date: [Item]] = [:]
    private let calendar = Calendar.current
    private let isTestEnvironment: Bool
    
    lazy var fetchedResultsController: NSFetchedResultsController<Item> = {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        if !isTestEnvironment {
            // Sadece production ortamında tarih filtresi uygula
            let startDate = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: Date()))!
            let endDate = calendar.date(byAdding: .day, value: 3, to: calendar.startOfDay(for: Date()))!
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: isTestEnvironment ? nil : "CalendarCache"
        )
        
        controller.delegate = self
        return controller
    }()
    
    init(context: NSManagedObjectContext, isTestEnvironment: Bool = false) {
        self.context = context
        self.isTestEnvironment = isTestEnvironment
        super.init()
        fetchTasks()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksUpdated),
            name: .tasksUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if !isTestEnvironment {
            NSFetchedResultsController<Item>.deleteCache(withName: "CalendarCache")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tasks = controller.fetchedObjects as? [Item] ?? []
            self.cachedTasks.removeAll()
            self.objectWillChange.send()
        }
    }
    
    @objc private func tasksUpdated() {
        DispatchQueue.main.async {
            self.fetchTasks()
        }
    }

    func fetchTasks() {
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.tasks = self.fetchedResultsController.fetchedObjects ?? []
                self.cachedTasks.removeAll()
            }
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    func tasksForDate(_ date: Date) -> [Item] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Önbellekten kontrol et
        if let cachedTasks = cachedTasks[startOfDay] {
            return filterTasksByCategory(cachedTasks)
        }
        
        // Önbellekte yoksa hesapla ve önbelleğe al
        let filteredTasks = tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return taskDate >= startOfDay && taskDate < endOfDay
        }
        
        cachedTasks[startOfDay] = filteredTasks
        return filterTasksByCategory(filteredTasks)
    }
    
    private func filterTasksByCategory(_ tasks: [Item]) -> [Item] {
        guard selectedCategory != .all else { return tasks }
        return tasks.filter { $0.category == selectedCategory.rawValue }
    }
    
    func hasCompletedTasks(for date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let tasksForDay = tasksForDate(startOfDay)
        return !tasksForDay.isEmpty && tasksForDay.contains { $0.completed }
    }
    
    func totalTasks(for date: Date) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        return tasksForDate(startOfDay).count
    }
    
    func toggleTaskCompletion(_ task: Item) {
        task.completed.toggle()
        saveContext()
        NotificationCenter.default.post(name: .tasksUpdated, object: nil)
    }
    
    private func saveContext() {
        do {
            try context.save()
            self.fetchTasks() // Context kaydedildikten sonra görevleri yeniden yükle
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        CalendarHelper.formattedDate(date)
    }
    
    func weekDay(_ date: Date) -> String {
        CalendarHelper.weekDay(date)
    }
    
    func dayNumber(_ date: Date) -> String {
        CalendarHelper.dayNumber(date)
    }
    
    func getDaysInWeek() -> [Date] {
        let today = calendar.startOfDay(for: Date())
        var days: [Date] = []
        
        // Bugünden 3 gün öncesinden başla
        if let startDate = calendar.date(byAdding: .day, value: -3, to: today) {
            var currentDate = startDate
            
            // 7 gün ekle
            for _ in 0..<7 {
                days.append(calendar.startOfDay(for: currentDate))
                if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDate
                }
            }
        }
        
        return days
    }
}

extension Notification.Name {
    static let calendarTasksUpdated = Notification.Name("calendarTasksUpdated")
}
