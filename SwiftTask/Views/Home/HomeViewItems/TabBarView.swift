//
//  TabBarView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 04.02.25.
//
import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel = TabBarViewModel()
    @Binding var navigateToHome: Bool
    @Binding var navigateToProfile: Bool
    @Binding var navigateToCalendar: Bool
    @Binding var navigateToFocus: Bool
    let onAddTask: () -> Void
    
    // Environment values for safe area
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Main Tab Bar
            HStack {
                leftTabs
                Spacer()
                rightTabs
            }
            .frame(height: TabBarViewModel.Constants.tabBarHeight)
            .background(viewModel.tabBarBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Add Button
            addButton
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private var leftTabs: some View {
        HStack(spacing: 20) {
            TabButton(
                icon: TabType.home.icon,
                isSelected: navigateToHome,
                action: {
                    viewModel.handleTabSelection(
                        navigateToHome: &navigateToHome,
                        navigateToProfile: &navigateToProfile,
                        navigateToCalendar: &navigateToCalendar,
                        navigateToFocus: &navigateToFocus,
                        selectedTab: .home
                    )
                }
            )
            
            TabButton(
                icon: TabType.calendar.icon,
                isSelected: navigateToCalendar,
                action: {
                    viewModel.handleTabSelection(
                        navigateToHome: &navigateToHome,
                        navigateToProfile: &navigateToProfile,
                        navigateToCalendar: &navigateToCalendar,
                        navigateToFocus: &navigateToFocus,
                        selectedTab: .calendar
                    )
                }
            )
        }
        .padding(.leading, 20)
    }
    
    private var rightTabs: some View {
        HStack(spacing: 20) {
            TabButton(
                icon: TabType.focus.icon,
                isSelected: navigateToFocus,
                action: {
                    viewModel.handleTabSelection(
                        navigateToHome: &navigateToHome,
                        navigateToProfile: &navigateToProfile,
                        navigateToCalendar: &navigateToCalendar,
                        navigateToFocus: &navigateToFocus,
                        selectedTab: .focus
                    )
                }
            )
            
            TabButton(
                icon: TabType.profile.icon,
                isSelected: navigateToProfile,
                action: {
                    viewModel.handleTabSelection(
                        navigateToHome: &navigateToHome,
                        navigateToProfile: &navigateToProfile,
                        navigateToCalendar: &navigateToCalendar,
                        navigateToFocus: &navigateToFocus,
                        selectedTab: .profile
                    )
                }
            )
        }
        .padding(.trailing, 20)
    }
    
    private var addButton: some View {
        Button(action: onAddTask) {
            Circle()
                .frame(width: TabBarViewModel.Constants.addButtonSize, height: TabBarViewModel.Constants.addButtonSize)
                .foregroundColor(viewModel.addButtonColor)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: viewModel.addButtonColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .offset(y: -30)
        .accessibilityLabel("Add New Task")
    }
}

#Preview {
    TabBarView(
        navigateToHome: .constant(false),
        navigateToProfile: .constant(false),
        navigateToCalendar: .constant(false),
        navigateToFocus: .constant(false),
        onAddTask: {}
    )
    .preferredColorScheme(.dark)
}
