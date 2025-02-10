//
//  TabBarItemsModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 09.02.25.
//

import Foundation

// Tab item model for better maintainability
struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let action: () -> Void
    let isSelected: Bool
}
