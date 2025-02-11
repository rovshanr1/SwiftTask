//
//  TabBarView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 04.02.25.
//
import SwiftUI

struct TabBarView: View {
    @Binding var navigateToHome: Bool
    @Binding var navigateToProfile: Bool
    let onAddTask: () -> Void
    
    // Environment values for safe area
    @Environment(\.colorScheme) var colorScheme
    
    // Constants
    private enum Constants {
        static let tabBarHeight: CGFloat = 70
        static let tabBarCornerRadius: CGFloat = 20
        static let tabBarSpacing: CGFloat = 50
        static let addButtonSize: CGFloat = 64
        static let addButtonIconSize: CGFloat = 32
        static let horizontalPadding: CGFloat = 20
    }
    
    private var tabBarBackground: Color {
        Color(red: 0.21, green: 0.21, blue: 0.21)
            .opacity(0.8)
    }
    
    private var addButtonColor: Color {
        Color(red: 1.00, green: 0.44, blue: 0.14)
    }
    
    var body: some View {
        ZStack {
            // Main Tab Bar
            HStack {
                leftTabs
                Spacer()
                rightTabs
            }
            .frame(height: Constants.tabBarHeight)
            .background(tabBarBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.tabBarCornerRadius))
            .padding(.horizontal, 16)
            // Add shadow for better visibility
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Add Button
            addButton
        }
    }
    
    private var leftTabs: some View {
        HStack(spacing: Constants.tabBarSpacing) {
            
//            TabButton(
//                icon: "calendar",
//                isSelected: false,
//                action: { /* Calendar action */ }
//            )
            
            TabButton(
                icon: "house",
                isSelected: navigateToHome,
                action: { navigateToHome = true }
            )
        }
        .padding(.leading, Constants.horizontalPadding)
    }
    
    private var rightTabs: some View {
        HStack(spacing: Constants.tabBarSpacing) {
            TabButton(
                icon: "person",
                isSelected: navigateToProfile,
                action: { navigateToProfile = true }
            )
            
//            TabButton(
//                icon: "clock",
//                isSelected: false,
//                action: { /* Clock action */ }
//            )
           
        }
        .padding(.trailing, Constants.horizontalPadding)
    }
    
    private var addButton: some View {
        Button(action: onAddTask) {
            Circle()
                .frame(width: Constants.addButtonSize, height: Constants.addButtonSize)
                .foregroundColor(addButtonColor)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: Constants.addButtonIconSize, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: addButtonColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .offset(y: -30)
        .accessibilityLabel("Add New Task")
    }
}

// Extracted Tab Button for reusability
struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .frame(width: 44, height: 44) // Better touch target
                .background(
                    isSelected ?
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    : nil
                )
                .animation(.easeInOut, value: isSelected)
        }
        .accessibilityLabel(icon.capitalized)
    }
}

#Preview {
    TabBarView(
        navigateToHome: .constant(false),
        navigateToProfile: .constant(false),
        onAddTask: {}
    )
    .preferredColorScheme(.dark)
}
