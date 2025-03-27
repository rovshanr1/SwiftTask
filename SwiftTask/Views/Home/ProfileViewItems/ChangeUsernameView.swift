import SwiftUI

struct ChangeUsernameView: View {
    @Binding var isPresented: Bool
    @Binding var newUserName: String
    @ObservedObject var viewModel: ProfileViewModel
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Change Username")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(themeManager.currentTheme.text)
                
                Divider()
                    .background(themeManager.currentTheme.secondaryText.opacity(0.3))
                    .padding(.horizontal, -24)
            }

            // Username Input
            VStack(alignment: .leading, spacing: 8) {
                Text("New Username")
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                
                TextField("", text: $newUserName, prompt: Text("Enter your new username")
                    .foregroundStyle(themeManager.currentTheme.secondaryText))
                    .foregroundColor(themeManager.currentTheme.text)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentTheme.secondaryBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.currentTheme.text.opacity(0.1), lineWidth: 1)
                    )
            }
            .padding(.top, 8)

            Spacer()

            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    if !newUserName.isEmpty {
                        viewModel.saveUserProfile(name: newUserName)
                        isPresented = false
                    }
                }) {
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeManager.currentTheme.accent)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(themeManager.currentTheme.secondaryBackground)
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
        .presentationDetents([.height(320)])
    }
} 