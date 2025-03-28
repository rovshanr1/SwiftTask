import SwiftUI

struct AboutSwiftTaskView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    private let appVersion = "1.1.0"
    private let features = [
        ("Task Management", "list.bullet.clipboard.fill", "Create, edit, and organize your daily tasks efficiently"),
        ("Focus Timer", "timer.circle.fill", "Stay productive with built-in Pomodoro timer"),
        ("Calendar View", "calendar.circle.fill", "Track your tasks and progress with calendar integration"),
        ("Statistics", "chart.bar.fill", "View your productivity stats and achievements")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("About SwiftTask")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(themeManager.currentTheme.text)
                
                Divider()
                    .background(themeManager.currentTheme.secondaryText.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // App Icon and Version
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(themeManager.currentTheme.accent)
                        
                        Text("Version \(appVersion)")
                            .font(.system(size: 14))
                            .foregroundStyle(themeManager.currentTheme.secondaryText)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Features")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.currentTheme.text)
                        
                        VStack(spacing: 16) {
                            ForEach(features, id: \.0) { feature in
                                HStack(spacing: 16) {
                                    Image(systemName: feature.1)
                                        .font(.system(size: 24))
                                        .foregroundStyle(themeManager.currentTheme.accent)
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(feature.0)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(themeManager.currentTheme.text)
                                        
                                        Text(feature.2)
                                            .font(.system(size: 14))
                                            .foregroundStyle(themeManager.currentTheme.secondaryText)
                                            .lineLimit(2)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Developer Info
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Developer")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.currentTheme.text)
                        
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(themeManager.currentTheme.accent)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rovshan Rasulov")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(themeManager.currentTheme.text)
                                
                                Text("iOS Developer")
                                    .font(.system(size: 14))
                                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                            }
                        }
                    }
                    
                    // Contact
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Contact")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.currentTheme.text)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                if let url = URL(string: "mailto:swifttask@icloud.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                LinkButton(
                                    icon: "envelope.fill",
                                    title: "Email",
                                    subtitle: "swifttask@icloud.com",
                                    theme: themeManager.currentTheme
                                )
                            }
                            
                            Button(action: {
                                if let url = URL(string: "https://studio.iss.az") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                LinkButton(
                                    icon: "globe",
                                    title: "Website",
                                    subtitle: "studio.iss.az",
                                    theme: themeManager.currentTheme
                                )
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
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
        .presentationDetents([.large])
    }
}

struct LinkButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let theme: ThemeColors
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(theme.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.text)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(theme.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(theme.text)
        }
        .padding(16)
        .background(theme.secondaryBackground)
        .cornerRadius(12)
    }
} 
