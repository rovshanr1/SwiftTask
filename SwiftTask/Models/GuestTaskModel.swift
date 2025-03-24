//
//  GuestTaskModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 24.03.25.
//

import Foundation

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var completed: Bool
    
    init(id: UUID = UUID(), title: String, description: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.completed = completed
    }
}
