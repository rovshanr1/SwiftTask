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
        VStack(spacing: 20) {
            Text("Change Profile Image")
                .font(.headline)
                .foregroundStyle(.white)
            
            Divider().background(Color.gray)
                .padding(8)
            if let selectedImage = selectedImage ?? UIImage(data: viewModel.profileImageData ?? Data()) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(radius: 5)
                }
            

            HStack {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text("Choose Photos")
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(width: 153, height: 48)
                }
                .onChange(of: selectedItem) {
                    Task{
                        if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                selectedImage = image
                                viewModel.updateProfileImage(image)
                            }
                        }
                    }
                }


                Button(action: {
                    showingCamera = true
                }) {
                    Text("Take Photo")
                        .foregroundStyle(.white)
                        .frame(width: 153, height: 48)
                        .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .cornerRadius(5)
                }
            }
            VStack{
                if selectedImage != nil || viewModel.profileImageData != nil{
                       Button(action: {
                           showDeleteAlert = true
                       }) {
                           Text("Remove Photo")
                               .foregroundStyle(.white)
                               .frame(width: 153, height: 48)
                               .background(Color.red)
                               .cornerRadius(5)
                       }
                       .transition(.opacity)
                       .alert(isPresented: $showDeleteAlert){
                           Alert(
                            title: Text("Are you sure?"),
                            message: Text("Are you sure you want to delete your profile photo?"),
                            primaryButton: .destructive(Text("Delete")) {
                                selectedImage = nil
                                viewModel.removeProfileImage()
                            }, secondaryButton: .cancel()
                           )
                       }
                   }
            }

        }
        .cornerRadius(15)
        .padding()
        .presentationDetents([.medium, .large])
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedImage, viewModel: viewModel)
        }
    }
}
