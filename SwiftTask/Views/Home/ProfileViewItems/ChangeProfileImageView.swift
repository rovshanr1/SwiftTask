//
//  ChangeProfileImageView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 06.02.25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct ChangeProfileImageView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Change Profile Image")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            // Profile Image Preview
            VStack(spacing: 20) {
                if let selectedImage = selectedImage ?? UIImage(data: viewModel.profileImageData ?? Data()) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.3), radius: 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.3), radius: 10)
                }
                
                Text("Upload a photo of yourself")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)

            // Action Buttons
            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 16))
                        Text("Choose from Library")
                    }
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
                .onChange(of: selectedItem) {
                    Task {
                        if let selectedItem,
                           let data = try? await selectedItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                            viewModel.updateProfileImage(image)
                        }
                    }
                }

                Button(action: { showingCamera = true }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                        Text("Take Photo")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                    .cornerRadius(12)
                }
                
                if selectedImage != nil || viewModel.profileImageData != nil {
                    Button(action: { showDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                            Text("Remove Photo")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(12)
                    }
                    .transition(.opacity)
                }
            }
            
            Spacer()
        }
        .padding(24)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.height(520)])
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedImage, viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
        .alert("Delete Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                selectedImage = nil
                viewModel.removeProfileImage()
            }
        } message: {
            Text("Are you sure you want to delete your profile photo?")
        }
    }
}
