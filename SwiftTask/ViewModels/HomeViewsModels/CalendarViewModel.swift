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
    
    lazy var fetchedResultsController: NSFetchedResultsController<Item> = {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        // Sadece bugünden 3 gün öncesi ve 3 gün sonrasını getir
        let startDate = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: Date()))!
        let endDate = calendar.date(byAdding: .day, value: 3, to: calendar.startOfDay(for: Date()))!
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: "CalendarCache"
        )
        
        controller.delegate = self
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
        NSFetchedResultsController<Item>.deleteCache(withName: "CalendarCache")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tasks = controller.fetchedObjects as? [Item] ?? []
            self.cachedTasks.removeAll()
            self.objectWillChange.send()
        }
    }
    
    @objc private func tasksUpdated() {
        DispatchQueue.global(qos: .userInitiated).async {
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
        
        // Önbellekten kontrol et
        if let cachedTasks = cachedTasks[startOfDay] {
            return selectedCategory == .all ? cachedTasks : cachedTasks.filter { $0.category == selectedCategory.rawValue }
        }
        
        // Önbellekte yoksa hesapla ve önbelleğe al
        let filteredTasks = tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return calendar.isDate(taskDate, inSameDayAs: date)
        }
        
        cachedTasks[startOfDay] = filteredTasks
        return selectedCategory == .all ? filteredTasks : filteredTasks.filter { $0.category == selectedCategory.rawValue }
    }
    
    func hasCompletedTasks(for date: Date) -> Bool {
        let dayTasks = tasksForDate(date)
        return !dayTasks.isEmpty && dayTasks.contains { $0.completed }
    }
    
    func totalTasks(for date: Date) -> Int {
        return tasksForDate(date).count
    }
    
    func toggleTaskCompletion(_ task: Item) {
        context.perform {
            task.completed.toggle()
            self.saveContext()
            NotificationCenter.default.post(name: .tasksUpdated, object: nil)
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
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
    
    private let weekDays: [Date] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }()

    func getDaysInWeek() -> [Date] {
        return weekDays
    }
}

extension Notification.Name {
    static let calendarTasksUpdated = Notification.Name("calendarTasksUpdated")
}
