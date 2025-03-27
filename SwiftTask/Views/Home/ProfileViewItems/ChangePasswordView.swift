//
//  ChangePasswordView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 07.02.25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Change Password")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            // Password Fields
            VStack(spacing: 20) {
                PasswordField(
                    title: "Current Password",
                    text: $currentPassword,
                    placeholder: "Enter current password"
                )
                
                PasswordField(
                    title: "New Password",
                    text: $newPassword,
                    placeholder: "Enter new password"
                )
                
                PasswordField(
                    title: "Confirm Password",
                    text: $confirmNewPassword,
                    placeholder: "Confirm new password"
                )
            }
            .padding(.top, 8)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: changePassword) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.00, green: 0.44, blue: 0.14),
                                Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(12)
                }
                .disabled(isLoading)
            }
        }
        .padding(24)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.height(520)])
    }

    private func changePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmNewPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        guard newPassword == confirmNewPassword else {
            errorMessage = "New passwords do not match."
            return
        }

        isLoading = true
        errorMessage = nil

        viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, error in
            isLoading = false
            if success {
                dismiss()
            } else {
                errorMessage = error ?? "An error occurred. Please try again."
            }
        }
    }
}

struct PasswordField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            
            SecureField("", text: $text, prompt: Text(placeholder)
                .foregroundStyle(.gray))
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.21, green: 0.21, blue: 0.21))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

