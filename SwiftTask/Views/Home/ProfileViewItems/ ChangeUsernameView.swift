//
//   ChangeUsernameView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 06.02.25.
//
import SwiftUI

struct ChangeUsernameView: View {
    @Binding var isPresented: Bool
    @Binding var newUserName: String
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Change Username")
                .font(.headline)
                .foregroundStyle(.white)

            Divider().background(Color.gray)
                .padding(8)
            
            TextField("Enter your new username", text: $newUserName)
                .foregroundColor(.white)
                .frame(width: 287, height: 43)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)

            HStack(spacing: 20) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(width: 153, height: 48)
                }

                Button(action: {
                    if !newUserName.isEmpty {
                        viewModel.saveUserProfile(name: newUserName)
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .foregroundStyle(.white)
                        .frame(width: 153, height: 48)
                        .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .cornerRadius(5)
                }
            }
            .padding()
        }
        .cornerRadius(15)
        .padding()
        .presentationDetents([.medium, .large])
    }
}


