import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.theme) var theme
    
    @State private var navigateToHome = false
    @State private var navigateToProfile = true
    @State private var navigateToFocus = false
    @State private var navigateToCalendar = false
    @State private var showingCustomModal = false
    @State private var userNameChanged = false
    @State private var showImagePicker = false
    @State private var showChangePasswordView = false
    @State private var showAboutView = false
    @State private var showThemeView = false
    @State private var newUserName = ""
    @State private var isLoggedOut = false
    @State private var deleteAccountPassword = ""
    @State private var showNotificationSettings = false

    var body: some View {
        NavigationStack {
            if isLoggedOut {
                IntroView()
                    .navigationBarBackButtonHidden(true)
                    .interactiveDismissDisabled()
            } else {
                ZStack {
                    themeManager.currentTheme.background
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
                    .ignoresSafeArea(.keyboard, edges: .bottom)
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
                .alert("Delete Account", isPresented: $viewModel.isShowingDeleteAccountAlert) {
                    SecureField("Enter your password", text: $deleteAccountPassword)
                    Button("Cancel", role: .cancel) {
                        deleteAccountPassword = ""
                    }
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAccount(password: deleteAccountPassword) { success, error in
                            deleteAccountPassword = ""
                            if success {
                                isLoggedOut = true
                            } else {
                                viewModel.deleteAccountError = error
                                viewModel.isShowingDeleteAccountConfirmation = true
                            }
                        }
                    }
                } message: {
                    Text("This action cannot be undone. Please enter your password to confirm.")
                        .foregroundColor(themeManager.currentTheme.text)
                }
                .alert("Error", isPresented: $viewModel.isShowingDeleteAccountConfirmation) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.deleteAccountError ?? "An unknown error occurred")
                }
            }
        }
    }
    
    @ViewBuilder
    private func profileViewContent() -> some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.title)
                .foregroundColor(themeManager.currentTheme.text)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            if let user = viewModel.user {
                VStack {
                    // Profile Image
                    if let imageData = viewModel.profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(themeManager.currentTheme.text.opacity(0.3), lineWidth: 1))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundStyle(themeManager.currentTheme.text)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(themeManager.currentTheme.text.opacity(0.3), lineWidth: 1))
                            .shadow(radius: 5)
                    }
                    
                    // User Info
                    Text(user.userName)
                        .font(.title)
                        .foregroundColor(themeManager.currentTheme.text)
                    
                    // Task Stats
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(homeViewModel.newItems.count)")
                                .font(.title2)
                                .foregroundColor(themeManager.currentTheme.text)
                            Text("Tasks Left")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryText)
                        }
                        .padding()
                        .frame(width: 154, height: 58)
                        .background(themeManager.currentTheme.secondaryBackground.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        
                        VStack {
                            Text("\(homeViewModel.completedTasks.count)")
                                .font(.title2)
                                .foregroundColor(themeManager.currentTheme.text)
                            Text("Tasks Done")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryText)
                        }
                        .padding()
                        .frame(width: 154, height: 58)
                        .background(themeManager.currentTheme.secondaryBackground.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
                
                settingsList()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.text))
                    .scaleEffect(1.5)
            }
        }
    }
    
    @ViewBuilder
    private func settingsList() -> some View {
        List {
            Section(header: Text("App Settings").foregroundStyle(themeManager.currentTheme.secondaryText)) {
                // Notifications
                Button(action: { showNotificationSettings = true }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("Notifications")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                .sheet(isPresented: $showNotificationSettings) {
                    NotificationSettingsView(context: PersistenceController.shared.viewContext)
                        .presentationBackground(themeManager.currentTheme.secondaryBackground)
                }
                
                // App Theme
                Button(action: { showThemeView = true }) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("App Theme")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                .sheet(isPresented: $showThemeView) {
                    AppThemeView()
                        .presentationBackground(themeManager.currentTheme.secondaryBackground)
                }
                
                // Language
                Button(action: {
                    // TODO: Implement language settings
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("Language")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Text("English")
                            .foregroundStyle(themeManager.currentTheme.secondaryText)
                            .font(.system(size: 14))
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                
                // About App
                Button(action: { showAboutView = true }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("About SwiftTask")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                .sheet(isPresented: $showAboutView) {
                    AboutSwiftTaskView()
                        .presentationBackground(themeManager.currentTheme.secondaryBackground)
                }
            }
            .listRowBackground(themeManager.currentTheme.background)

            Section(header: Text("Account").foregroundStyle(themeManager.currentTheme.secondaryText)) {
                // Change account name button
                Button(action: { showingCustomModal = true }) {
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("Change account name")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                .sheet(isPresented: $showingCustomModal) {
                    ChangeUsernameView(isPresented: $showingCustomModal, newUserName: $newUserName, viewModel: viewModel)
                        .presentationBackground(themeManager.currentTheme.secondaryBackground)
                }
                
                // Change image button
                Button(action: { showImagePicker = true }) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("Change account Image")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ChangeProfileImageView(viewModel: viewModel)
                        .presentationBackground(themeManager.currentTheme.secondaryBackground)
                }
                
                // Change password button
                Button(action: { showChangePasswordView = true }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(themeManager.currentTheme.accent)
                            .frame(width: 24, height: 24)
                        Text("Change account password")
                            .foregroundStyle(themeManager.currentTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(themeManager.currentTheme.text)
                    }
                }
                .sheet(isPresented: $showChangePasswordView) {
                    ChangePasswordView(viewModel: viewModel)
                        .presentationBackground(themeManager.currentTheme.secondaryBackground)
                }
                
                // Delete Account Button
                Button(action: { viewModel.isShowingDeleteAccountAlert = true }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.xmark.fill")
                            .foregroundStyle(.red)
                            .frame(width: 24, height: 24)
                        Text("Delete Account")
                            .foregroundStyle(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.red)
                    }
                }
            }
            .listRowBackground(themeManager.currentTheme.background)
            
            Section(header: Text("SwiftTask").foregroundStyle(themeManager.currentTheme.secondaryText)) {
                Button(action: {
                    viewModel.logout()
                    isLoggedOut = true
                }) {
                    HStack {
                        Image("logout")
                            .frame(width: 24, height: 24)
                        Text("Logout")
                            .foregroundStyle(.red)
                    }
                }
            }
            .listRowBackground(themeManager.currentTheme.background)
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.currentTheme.background)
    }
}

enum NavigationDestination: Hashable {
    case home
    case focus
    case calendar
    case intro
}



