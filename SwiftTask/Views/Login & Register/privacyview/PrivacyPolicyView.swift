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
                    **Last Updated: [09.02.2025]**
                    
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
                        • Profile Photo: Users can upload a profile photo, which is stored locally on the device. This photo is never shared with third parties
                        """)
                    
                    Text("2. Use of Data")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **The data we collect may be used for the following purposes**:
                        • Creating and managing user accounts.
                        • Managing and storing tasks.
                        • Storing profile information necessary for app functionality.
                        • Analyzing app performance and improving user experience.
                        """)
                    
                    Text("3. Data Sharing")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **SwiftTask does not share, sell, or rent user data to third parties. Profile photos and other personal data are stored locally on the device and are not uploaded to any server**
                        """)
                    
                    Text("4. Data Security")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **SwiftTask implements robust security measures to protect your personal data. Your information is transmitted through secure connections, and access to your data is limited to authorized personnel only.**
                        """)
                    
                    Text("5. User Rights")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **Users have the right to access, update, or delete their account information at any time. Profile photos uploaded by the user are stored locally on the device, and users can remove them at any time.**
                        """)
                    
                    Text("6. Changes to the Policy")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **This Privacy Policy may be updated periodically. Any changes will be posted here with the updated date.**
                        """)
                    
                    Text("7. Contact Us")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **If you have any questions regarding our privacy policy, please contact us at:**
                        
                        • 📧 Email: [swifttask@icloud.com]
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

#Preview {
    PrivacyPolicyView()
}
