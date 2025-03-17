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
                    **Last Updated: [09.02.2025]**

                    By accessing or using SwiftTask, you confirm that you have read, understood, and agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, please do not use SwiftTask.
                    """)
                    
                    Text("1. Use of the App")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask is designed to help users organize, track, and manage tasks. The app is intended for **personal, non-commercial** use only. Any unauthorized or harmful use of the app is strictly prohibited.
                        """)
                    
                    Text("2. Account Creation and Security")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        **To use SwiftTask, you may be required to create an account. You agree to**:
                        • Provide accurate and up-to-date information (email address, username).
                        • Maintain the security of your account credentials.
                        • Accept responsibility for all activities under your account.
                        """)
                    
                    Text("3. Profile Photo and Personal Information")
                        .font(.headline)
                        .padding(.top, 10)
                    VStack(alignment: .leading){
                        Text("""
                        SwiftTask allows users to upload and edit profile photos. These photos are stored locally on the device and are never uploaded to a server. Personal information such as username and email address is collected via Firebase and used solely for account-related purposes.
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
                        • Interfere with the app’s normal functionality or attempt to gain unauthorized access.
                        """)
                    
                    Text("5. Account Termination and Suspension")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask reserves the right to **suspend or terminate** accounts that violate these terms without prior notice. Users can delete their accounts at any time.
                        """)
                    
                    Text("6. App Updates")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask may periodically release updates, including new features and improvements. Users are responsible for ensuring they use the latest version for the best experience.
                        """)
                    
                    Text("7. Disclaimer & Limitation of Liability")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                        SwiftTask is provided "as is" without any warranties. We do not guarantee that the app will always function error-free.
                        To the maximum extent permitted by law, SwiftTask is not responsible for any direct, indirect, or incidental damages caused by the use of the app.
                        """)
                    
                    Text("8. Changes to These Terms")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                    SwiftTask reserves the right to update these terms at any time. Users will be notified of major changes, but it is their responsibility to review these terms periodically.
                    """)
                    
                    Text("9. Contact")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("""
                    **If you have any questions, you can contact us at**:
                    • 📧 Email: [swifttask@icloud.com]
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
