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
            Text("Change Profile Image")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Profile Image Preview
            VStack(spacing: 20) {
                if let selectedImage = selectedImage ?? UIImage(data: viewModel.profileImageData ?? Data()) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(radius: 10)
                }
                
                Text("Upload a photo of yourself")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)

            // Action Buttons
            VStack(spacing: 12) {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Choose from Library")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
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
                        Text("Take Photo")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                    .cornerRadius(12)
                }
                
                if selectedImage != nil || viewModel.profileImageData != nil {
                    Button(action: { showDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Remove Photo")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(12)
                    }
                    .transition(.opacity)
                }
            }
        }
        .padding(24)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.height(500)])
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedImage, viewModel: viewModel)
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
