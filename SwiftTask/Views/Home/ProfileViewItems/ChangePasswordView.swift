//
//  ChangePasswordView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 07.02.25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = ThemeManager.shared
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
                    .foregroundStyle(themeManager.currentTheme.text)
                
                Divider()
                    .background(themeManager.currentTheme.secondaryText.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            // Password Fields
            VStack(spacing: 20) {
                PasswordField(
                    title: "Current Password",
                    text: $currentPassword,
                    placeholder: "Enter current password",
                    theme: themeManager.currentTheme
                )
                
                PasswordField(
                    title: "New Password",
                    text: $newPassword,
                    placeholder: "Enter new password",
                    theme: themeManager.currentTheme
                )
                
                PasswordField(
                    title: "Confirm Password",
                    text: $confirmNewPassword,
                    placeholder: "Confirm new password",
                    theme: themeManager.currentTheme
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
                                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.text))
                        } else {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(themeManager.currentTheme.accent)
                    .foregroundStyle(themeManager.currentTheme.text)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeManager.currentTheme.secondaryBackground)
                        .cornerRadius(12)
                }
                .disabled(isLoading)
            }
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
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
    let theme: ThemeColors
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(theme.secondaryText)
            
            SecureField("", text: $text, prompt: Text(placeholder)
                .foregroundStyle(theme.secondaryText))
                .foregroundColor(theme.text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondaryBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.text.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

