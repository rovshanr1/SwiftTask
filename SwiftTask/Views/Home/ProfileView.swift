import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigateToHome = false
    @State private var navigateToProfile = true
    @State private var navigateToFocus = false
    @State private var navigateToCalendar = false
    @State private var showingCustomModal = false
    @State private var userNameChanged = false
    @State private var showImagePicker = false
    @State private var showChangePasswordView = false
    @State private var newUserName = ""
    @State private var isLoggedOut = false

    var body: some View {
        NavigationStack{
            if isLoggedOut {
                IntroView()
                    .navigationBarBackButtonHidden(true)
                    .interactiveDismissDisabled()
            } else {
                ZStack {
                    Color(red: 0.07, green: 0.07, blue: 0.07)
                        .ignoresSafeArea()
                    
                    VStack {
                        profileViewContent()
                        Spacer()
                        TabBarView(
                            navigateToHome: $navigateToHome,
                            navigateToProfile: .constant(true),
                            navigateToCalendar: $navigateToCalendar,
                            navigateToFocus: $navigateToFocus,
                            onAddTask: { /* Profile does not support adding tasks */ }
                        )
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView(context: PersistenceController.shared.viewContext)
                        .navigationBarBackButtonHidden(true)
                }
                .navigationDestination(isPresented: $navigateToFocus) {
                    FocusView()
                        .navigationBarBackButtonHidden(true)
                }
                .navigationDestination(isPresented: $navigateToCalendar) {
                    CalendarView(context: PersistenceController.shared.viewContext)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onAppear {
            homeViewModel.fetchItems()
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
                        Text("Profile")
                          .font(.title)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
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
                                .foregroundStyle(.white)
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
                                Text("\(homeViewModel.newItems.count)") // Uncompleted tasks
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
                                Text("\(homeViewModel.completedTasks.count)")
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
//                        Section(header: Text("Settings").foregroundColor(.gray)) {
//                            Button(action: {}) {
//                                HStack {
//                                    Image("setting-2")
//                                        .frame(width: 24, height: 24)
//                                    Text("App Settings")
//                                        .foregroundStyle(.white)
//                                }
//                            }
//                        }
                        
                        Section(header: Text("Account").foregroundStyle(Color(red: 0.69, green: 0.69, blue: 0.69))){
                            //Change accountName button
                            Button(action: {
                                showingCustomModal = true
                            }){
                                HStack{
                                    Image("user")
                                        .foregroundStyle(.white)
                                        .frame(width: 24, height: 24)
                                    Text("Change account name")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white)
                                }
                            }
                            .sheet(isPresented: $showingCustomModal) {
                                    ChangeUsernameView(isPresented: $showingCustomModal, newUserName: $newUserName, viewModel: viewModel)
                                    .presentationBackground(Color(red: 0.12, green: 0.12, blue: 0.12))
                            }
                            
                            // Display changed name if updated
                            if userNameChanged {
                                Text("Username updated to: \(newUserName)")
                                .foregroundColor(.green)
                            }
                            
                            // Change image button
                            Button(action: {
                                showImagePicker = true
                            }){
                                HStack {
                                    Image("camera")
                                        .foregroundStyle(.white)
                                        .frame(width: 24, height: 24)
                                    Text("Change account Image")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white)
                                }
                            }.sheet(isPresented: $showImagePicker) {
                                ChangeProfileImageView(viewModel: viewModel)
                                    .presentationBackground(Color(red: 0.12, green: 0.12, blue: 0.12))
                            }
   
                            //Change password button
                            Button(action:{
                                showChangePasswordView = true
                            }){
                                HStack{
                                    Image("key")
                                        .foregroundStyle(.white)
                                        .frame(width: 24, height: 24)
                                    Text("Change account password")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white)
                                }
                            }.sheet(isPresented: $showChangePasswordView) {
                                ChangePasswordView(viewModel: viewModel)
                                    .presentationBackground(Color(red: 0.12, green: 0.12, blue: 0.12))
                            
                            }
                            
                        }
                        .listRowBackground(Color(red: 0.07, green: 0.07, blue: 0.07))
                        Section(header: Text("SwiftTask").foregroundStyle(Color(red: 0.69, green: 0.69, blue: 0.69))){
                            Button(action: {
                                viewModel.logout()
                                isLoggedOut = true
                            }) {
                                HStack{
                                    Image("logout")
                                        .frame(width:24, height: 24)
                                    Text("Logout")
                                        .foregroundStyle(Color(red: 1.00, green: 0.29, blue: 0.29))
                                }
                            }
                        }
                        .listRowBackground(Color(red: 0.07, green: 0.07, blue: 0.07))
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(red: 0.07, green: 0.07, blue: 0.07))
                    
                } else {
                    Text("No profile data found")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

enum NavigationDestination: Hashable {
    case home
    case focus
    case calendar
    case intro
}



