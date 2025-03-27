import SwiftUI

struct AboutSwiftTaskView: View {
    @Environment(\.dismiss) var dismiss
    
    private let appVersion = "1.0.0"
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
                    .foregroundStyle(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // App Icon and Version
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        
                        Text("Version \(appVersion)")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Features")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 16) {
                            ForEach(features, id: \.0) { feature in
                                HStack(spacing: 16) {
                                    Image(systemName: feature.1)
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(feature.0)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(.white)
                                        
                                        Text(feature.2)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.gray)
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
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rovshan Rasulov")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                Text("iOS Developer")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    
                    // Contact
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Contact")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 16) {
                            LinkButton(
                                icon: "envelope.fill",
                                title: "Email",
                                subtitle: "support@swifttask.com"
                            )
                            
                            LinkButton(
                                icon: "globe",
                                title: "Website",
                                subtitle: "www.swifttask.com"
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Close Button
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.large])
    }
}

struct LinkButton: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
        .cornerRadius(12)
    }
} 