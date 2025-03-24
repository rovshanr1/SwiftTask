//
//  GuestViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 24.03.25.
//

import Foundation
import SwiftUI

class GuestViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var showingSheet = false
    @Published var showingDeleteAlert = false
    @Published var showingLoginPrompt = false
    @Published var itemToDelete: TaskItem?
    @Published var newTaskTitle = ""
    @Published var newTaskDescription = ""
    
    private let tasksKey = "guest_tasks"
    
    init() {
        loadTasks()
    }
    
    // MARK: - Task Management
    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let task = TaskItem(
            title: newTaskTitle,
            description: newTaskDescription,
            completed: false
        )
        
        tasks.append(task)
        saveTasks()
        
        newTaskTitle = ""
        newTaskDescription = ""
        showingSheet = false
    }
    
    func editTask(item: TaskItem, newTitle: String, newDescription: String) {
        if let index = tasks.firstIndex(where: { $0.id == item.id }) {
            var updatedTask = tasks[index]
            updatedTask.title = newTitle
            updatedTask.description = newDescription
            tasks[index] = updatedTask
            saveTasks()
        }
    }
    
    func deleteTask(item: TaskItem) {
        tasks.removeAll { $0.id == item.id }
        saveTasks()
        itemToDelete = nil
    }
    
    func toggleTaskCompletion(item: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == item.id }) {
            tasks[index].completed.toggle()
            saveTasks()
        }
    }
    
    func showDeleteAlert(for item: TaskItem) {
        itemToDelete = item
        showingDeleteAlert = true
    }
    
    // MARK: - Persistence
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
        }
    }
    
    func clearTasks() {
        tasks = []
        UserDefaults.standard.removeObject(forKey: tasksKey)
    }
}
