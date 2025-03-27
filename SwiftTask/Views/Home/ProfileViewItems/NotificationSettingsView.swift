import SwiftUI
import CoreData

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: NotificationSettingsViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showTimePicker = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: NotificationSettingsViewModel(context: context))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Notifications")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(themeManager.currentTheme.text)
                
                Divider()
                    .background(themeManager.currentTheme.secondaryText.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Main Toggle
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Enable Notifications")
                            .foregroundStyle(themeManager.currentTheme.text)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.settings.isEnabled)
                            .tint(themeManager.currentTheme.accent)
                            .onChange(of: viewModel.settings.isEnabled) { oldValue, newValue in
                                if newValue {
                                    viewModel.requestNotificationPermission()
                                }
                            }
                    }
                    .padding()
                    .background(themeManager.currentTheme.secondaryBackground)
                    .cornerRadius(12)
                    
                    if viewModel.settings.isEnabled {
                        // Daily Reminder Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Reminder")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(themeManager.currentTheme.text)
                            
                            Toggle("Enable Daily Reminder", isOn: $viewModel.settings.dailyReminder)
                                .tint(themeManager.currentTheme.accent)
                                .foregroundStyle(themeManager.currentTheme.text)
                            
                            if viewModel.settings.dailyReminder {
                                Button(action: { showTimePicker = true }) {
                                    HStack {
                                        Text("Reminder Time")
                                            .foregroundStyle(themeManager.currentTheme.text)
                                        Spacer()
                                        Text(viewModel.settings.reminderTime, style: .time)
                                            .foregroundStyle(themeManager.currentTheme.secondaryText)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(themeManager.currentTheme.secondaryBackground)
                        .cornerRadius(12)
                        
                        // Task Due Reminder
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Task Reminders")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(themeManager.currentTheme.text)
                            
                            Toggle("Task Due Reminders", isOn: $viewModel.settings.taskDueReminder)
                                .tint(themeManager.currentTheme.accent)
                                .foregroundStyle(themeManager.currentTheme.text)
                        }
                        .padding()
                        .background(themeManager.currentTheme.secondaryBackground)
                        .cornerRadius(12)
                        
                        // Sound and Vibration
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sound & Haptics")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(themeManager.currentTheme.text)
                            
                            Toggle("Sound", isOn: $viewModel.settings.soundEnabled)
                                .tint(themeManager.currentTheme.accent)
                                .foregroundStyle(themeManager.currentTheme.text)
                            
                            Toggle("Vibration", isOn: $viewModel.settings.vibrationEnabled)
                                .tint(themeManager.currentTheme.accent)
                                .foregroundStyle(themeManager.currentTheme.text)
                        }
                        .padding()
                        .background(themeManager.currentTheme.secondaryBackground)
                        .cornerRadius(12)
                    }
                }
            }
            
            // Close Button
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(themeManager.currentTheme.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(themeManager.currentTheme.secondaryBackground)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
        .sheet(isPresented: $showTimePicker) {
            NavigationView {
                DatePicker("Select Time", selection: $viewModel.settings.reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .navigationBarItems(
                        trailing: Button("Done") {
                            showTimePicker = false
                            viewModel.updateReminderTime(viewModel.settings.reminderTime)
                        }
                    )
            }
            .presentationDetents([.height(300)])
        }
        .onAppear {
            viewModel.checkNotificationStatus()
        }
    }
} 
