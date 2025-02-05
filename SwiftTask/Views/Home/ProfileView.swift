import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    @State private var navigateToIntroView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    profileViewContent()
                    Spacer()
                    TabBarView(
                        navigateToHome: $navigateToHome,
                        navigateToProfile: .constant(false),
                        onAddTask: {}
                    )
                }
                .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(context: PersistenceController.shared.viewContext)
            }
        }
    }

    @ViewBuilder
    private func profileViewContent() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    if let user = viewModel.user {
                        // Profile Image
                        if let imageData = viewModel.profileImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }

                        // Edit Profile Image Button
                        PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                            Text("Edit Profile Image")
                                .foregroundColor(.blue)
                        }

                        // User Info
                        Text(user.userName)
                            .font(.title)
                            .foregroundColor(.white)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        // Task Stats
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(user.taskDone)")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Tasks Done")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            VStack {
                                Text("\(user.taskLeft)")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Tasks Left")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        VStack(spacing: 20){
                            Text("No profile data found")
                                .foregroundColor(.white)
                            Button(action: {
                                viewModel.logout()
                            }){
                                Text("Logout")
                                foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}
