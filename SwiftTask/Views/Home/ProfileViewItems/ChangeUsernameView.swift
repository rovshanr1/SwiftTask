import SwiftUI

struct ChangeUsernameView: View {
    @Binding var isPresented: Bool
    @Binding var newUserName: String
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Change Username")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, -24)
            }

            // Username Input
            VStack(alignment: .leading, spacing: 8) {
                Text("New Username")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                TextField("", text: $newUserName, prompt: Text("Enter your new username")
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
                        .foregroundStyle(.white)
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
                        .cornerRadius(12)
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.height(320)])
    }
} 