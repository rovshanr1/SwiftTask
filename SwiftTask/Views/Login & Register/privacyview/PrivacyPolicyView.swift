//
//  PrivacyPolicyView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 10.02.25.
//


import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigateToRegister = false
    @State private var loginViewModel = LoginViewModel()
    @State private var showLoginScreen = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("""
                    **Last Updated: [29.03.2025]**
                    
                    SwiftTask values the privacy of its users. This Privacy Policy explains how we collect, use, protect, and share the personal data we collect during your use of the SwiftTask app.
                    
                    - **Data Collection**: We collect minimal personal data.
                    - **Usage**: Your data is used to improve our services.
                    - **Third-party Sharing**: We do not sell your data.
                    
                    Please read the full privacy policy below.
                    """)
                    
                    Text("1. Data Collected")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **SwiftTask collects the following types of data**:
                        
                        • Personal Information: Information such as your username and email address is collected via Firebase for account management purposes only.
                        • Profile Photo: Users can upload a profile photo, which is stored locally on the device. This photo is never shared with third parties.
                        • Task Data: Task information including titles, descriptions, categories, priorities, and completion status.
                        • Theme Preferences: Your selected app theme settings are stored locally.
                        • Notification Preferences: Your notification settings for task reminders.
                        """)
                    
                    Text("2. Use of Data")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **The data we collect may be used for the following purposes**:
                        • Creating and managing user accounts.
                        • Managing and storing tasks with categories and priorities.
                        • Storing profile information necessary for app functionality.
                        • Managing notification preferences and sending task reminders.
                        • Customizing app appearance through theme settings.
                        • Analyzing app performance and improving user experience.
                        • Syncing tasks between local storage and cloud for data backup.
                        """)
                    
                    Text("3. Data Sharing")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **SwiftTask does not share, sell, or rent user data to third parties. Profile photos and task data are primarily stored locally on the device, with task data being securely synced to Firebase for backup purposes only.**
                        """)
                    
                    Text("4. Data Security")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **SwiftTask implements robust security measures to protect your personal data. Your information is transmitted through secure connections, and access to your data is limited to authorized personnel only. We use Firebase Authentication for secure user authentication and CoreData for secure local storage.**
                        """)
                    
                    Text("5. User Rights")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **Users have the right to:**
                        • Access, update, or delete their account information at any time
                        • Manage their notification preferences
                        • Control their task data and profile information
                        • Choose their preferred app theme
                        • Remove their profile photo at any time
                        • Export or delete their task data
                        """)
                    
                    Text("6. Changes to the Policy")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **This Privacy Policy may be updated periodically to reflect changes in our data practices or app functionality. Any changes will be posted here with the updated date.**
                        """)
                    
                    Text("7. Contact Us")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **If you have any questions, you can contact us at:**
                        
                        • 📧 Email: [swifttask@icloud.com]
                        • 🌐 Website: [studio.iss.az]
                        """)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                CreateAccountView(loginviewModel: loginViewModel, showRegisterScreen: $navigateToRegister, showLoginScreen: $showLoginScreen)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}


