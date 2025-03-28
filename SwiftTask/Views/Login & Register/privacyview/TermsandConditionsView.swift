//
//  TermsandConditionsView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 10.02.25.
//

import SwiftUI

struct TermsandConditionsView: View {
    @Environment(\.dismiss) var dismiss
    @State var navigateToRegister = false
    @State var navigateToPrivacyPolicy = false
    @State private var loginViewModel = LoginViewModel()
    @State private var showLoginScreen = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text("""
                    **Last Updated: [29.03.2025]**

                    By accessing or using SwiftTask, you confirm that you have read, understood, and agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, please do not use SwiftTask.
                    """)
                    
                    Text("1. Use of the App")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask is designed to help users organize, track, and manage tasks with advanced features including task categorization, priority settings, and customizable themes. The app is intended for **personal, non-commercial** use only. Any unauthorized or harmful use of the app is strictly prohibited.
                        """)
                    
                    Text("2. Account Creation and Security")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **To use SwiftTask, you may be required to create an account. You agree to**:
                        • Provide accurate and up-to-date information (email address, username).
                        • Maintain the security of your account credentials.
                        • Accept responsibility for all activities under your account.
                        • Enable or disable notifications based on your preferences.
                        • Manage your task data responsibly.
                        """)
                    
                    Text("3. Profile Photo and Personal Information")
                        .font(.headline)
                        .padding(.top, 10)
                    VStack(alignment: .leading){
                        Text("""
                        SwiftTask allows users to upload and edit profile photos. These photos are stored locally on the device and are never uploaded to a server. Personal information such as username, email address, task data, and app preferences are managed securely through Firebase and local storage. Task data is synced with Firebase for backup purposes while maintaining user privacy.
                        For more details on how we handle your data, please review our
                        """)
                        Button(action: {
                            navigateToPrivacyPolicy = true
                        }) {
                            Text("Privacy Policy")
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .navigationDestination(isPresented: $navigateToPrivacyPolicy){
                        PrivacyPolicyView()
                    }
                    
                    Text("4. Prohibited Actions")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **You agree not to**:
                        • Sell, share, or misuse personal data.
                        • Engage in illegal, harmful, or fraudulent activities through the app.
                        • Interfere with the app's normal functionality or attempt to gain unauthorized access.
                        • Abuse the notification system or task management features.
                        • Attempt to bypass security measures or authentication systems.
                        """)
                    
                    Text("5. Account Termination and Data Management")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask reserves the right to **suspend or terminate** accounts that violate these terms without prior notice. Users can delete their accounts at any time, which will remove all associated data from our systems. Users are responsible for backing up their important task data before account deletion.
                        """)
                    
                    Text("6. App Features and Updates")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask may periodically release updates, including new features, theme options, notification capabilities, and general improvements. Users are responsible for:
                        • Keeping the app updated to the latest version
                        • Managing their notification preferences
                        • Configuring theme settings appropriately
                        • Maintaining their task categories and priorities
                        """)
                    
                    Text("7. Disclaimer & Limitation of Liability")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask is provided "as is" without any warranties. While we strive to maintain reliable task synchronization and notification delivery, we do not guarantee that the app will always function error-free or that notifications will be delivered instantly.
                        To the maximum extent permitted by law, SwiftTask is not responsible for any direct, indirect, or incidental damages caused by the use of the app, including but not limited to data loss or notification failures.
                        """)
                    
                    Text("8. Changes to These Terms")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask reserves the right to update these terms at any time to reflect new features, capabilities, or legal requirements. Users will be notified of major changes, but it is their responsibility to review these terms periodically.
                        """)
                    
                    Text("9. Contact")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **If you have any questions, you can contact us at**:
                        • 📧 Email: [swifttask@icloud.com]
                        • 🌐 Website: [studio.iss.az]
                        """)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Terms and Conditions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToRegister){
                CreateAccountView(loginviewModel: loginViewModel, showRegisterScreen: $navigateToRegister, showLoginScreen: $showLoginScreen)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    TermsandConditionsView()
}
