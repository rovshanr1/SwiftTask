import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    @State private var navigateToIntroView = false
    @State private var showingCustomModal = false
    @State private var newUserName = ""
    @State private var userNameChanged = false
   
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
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("Profile")
                            .font(.title)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(context: PersistenceController.shared.viewContext)
            }
            .navigationDestination(isPresented: $navigateToIntroView) {
                IntroView()
            }
            .sheet(isPresented: $showingCustomModal) {
                ChangeUsernameView(isPresented: $showingCustomModal, newUserName: $newUserName, viewModel: viewModel)
            }

        }
    }
    
    @ViewBuilder
    private func profileViewContent() -> some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                if let user = viewModel.user {
                    VStack{
                        // Profile Image
                        if let imageData = viewModel.profileImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
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
                        // User Info
                        Text(user.userName)
                            .font(.title)
                            .foregroundColor(.white)
                        
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
                            .padding()
                            .frame(width: 154, height: 58)
                            .background(Color(red: 0.21, green: 0.21, blue: 0.21).opacity(0.3))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            
                            VStack {
                                Text("\(user.taskLeft)")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Tasks Left")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(width: 154, height: 58)
                            .background(Color(red: 0.21, green: 0.21, blue: 0.21).opacity(0.3))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                    }
                    
                    List {
                        Section(header: Text("Settings").foregroundColor(.gray)) {
                            Button(action: {}) {
                                HStack {
                                    Image("setting-2")
                                        .frame(width: 24, height: 24)
                                    Text("App Settings")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        Section(header: Text("Account").foregroundStyle(.gray)){
                            //Change accountName button
                            Button(action: {
                                showingCustomModal = true
                            }){
                                HStack{
                                    Image("user")
                                        .frame(width: 24, height: 24)
                                    Text("Change account name")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            // Display changed name if updated
                            if userNameChanged {
                                Text("Username updated to: \(newUserName)")
                                .foregroundColor(.green)
                            }
                            
                            // Change image button
                            Button(action: {
                            }){
                                HStack {
                                    Image("camera")
                                        .frame(width: 24, height: 24)
                                    Text("Change account Image")
                                        .foregroundStyle(.white)
                                }
                            }
   
                            //Change password button
                            Button(action:{}){
                                HStack{
                                    Image("key")
                                        .frame(width: 24, height: 24)
                                    Text("Change account password")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                        }
                        Section(header: Text("SwiftTask").foregroundStyle(.gray)){
                            //Logout button
                            Button(action: {
                                viewModel.logout()
                                navigateToIntroView  = true
                            }) {
                                HStack{
                                    Image("logout")
                                        .frame(width:24, height: 24)
                                    Text("Logout")
                                        .foregroundStyle(Color(red: 1.00, green: 0.29, blue: 0.29))
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .scrollContentBackground(.hidden)
                    .background(Color(red: 0.07, green: 0.07, blue: 0.07))
                    
                } else {
                    Text("No profile data found")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    ProfileView()
//}
