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
            VStack(spacing: 20) {
                
                Text("Change account password")
                    .font(.headline)
                    .foregroundStyle(.white)

                Divider().background(Color.gray)
                    .padding(8)
                
                SecureField("Current Password", text: $currentPassword)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 352, height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                        )
                
                SecureField("New Password", text: $newPassword)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 352, height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                        )
                
                SecureField("Save", text: $confirmNewPassword)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 352, height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                        )
                
                
                HStack(spacing: 20){
                    Button(action: {
                        dismiss()
                    }){
                        Text("Cacnel")
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(width: 153, height: 48)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button(action: changePassword) {
                            Text("Change Password")
                                .foregroundStyle(.white)
                                .frame(width: 153, height: 48)
                                .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                                .cornerRadius(5)
                        }
                        .padding()
                    }
                }
            }
            .cornerRadius(15)
            .padding()
            
                
            
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

