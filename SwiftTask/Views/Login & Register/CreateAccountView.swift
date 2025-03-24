import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var loginviewModel: LoginViewModel
    @StateObject private var viewModel = CreateAccountViewModel()
    @Binding var showRegisterScreen: Bool
    @Binding var showLoginScreen: Bool
    @FocusState private var isKeyboardActive: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create Account")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)
                        
                        // Form Fields Section
                        formFieldsSection
                        
                        // Action Buttons Section
                        actionButtonsSection
                        
                        // Terms Section
                        termsSection
                        
                        // Login Link Section
                        loginLinkSection
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
        }
    }
    
    // MARK: - View Components
    private var formFieldsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            CustomTextField(
                text: $viewModel.username,
                title: "Username",
                placeholder: "Enter your Username",
                icon: "person.fill"
            )
            
            CustomTextField(
                text: $viewModel.email,
                title: "Email",
                placeholder: "Enter your Email",
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )
            
            CustomSecureField(
                text: $viewModel.password,
                title: "Password",
                placeholder: "Enter your Password",
                icon: "lock.fill",
                infoText: "Password must be at least 8 characters long and contain uppercase, lowercase, number, and special character."
            )
            
            CustomSecureField(
                text: $viewModel.confirmPassword,
                title: "Confirm Password",
                placeholder: "Confirm your Password",
                icon: "lock.shield.fill",
                infoText: "Please enter your password again to confirm it matches."
            )
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        Button(action: {
            handleRegistration()
        }) {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundStyle(.white)
                } else {
                    Text("Register")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.customGradient)
                        .cornerRadius(15)
                }
            }
        }
        .disabled(viewModel.isLoading)
        .padding(.top, 20)
    }
    
    private var termsSection: some View {
        VStack(spacing: 10) {
            CustomToggle(
                isOn: $viewModel.isConditionsAccepted,
                text: "I agree to the Terms and Conditions"
            )
            
            CustomToggle(
                isOn: $viewModel.isPrivacyAccepted,
                text: "I agree to the Privacy Policy"
            )
        }
    }
    
    private var loginLinkSection: some View {
        Button(action: {
            showLoginScreen = true
        }) {
            Text("Already have an account? Log in")
                .foregroundColor(.customAccent)
                .underline()
        }
        .navigationDestination(isPresented: $showLoginScreen) {
            LoginView(showLoginScreen: $showLoginScreen)
        }
        .padding(.top, 10)
    }
    
    private var backButton: some View {
        Button(action: {
            showRegisterScreen = false
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Helper Methods
    private func handleRegistration() {
        guard viewModel.isPrivacyAccepted && viewModel.isConditionsAccepted else {
            viewModel.errorMessage = "Please accept Privacy Policy and Terms & Conditions"
            return
        }
        
        guard !viewModel.username.isEmpty && !viewModel.email.isEmpty &&
              !viewModel.password.isEmpty && !viewModel.confirmPassword.isEmpty else {
            viewModel.errorMessage = "All fields are required."
            return
        }
        
        guard viewModel.password == viewModel.confirmPassword else {
            viewModel.errorMessage = "Passwords do not match."
            return
        }
        
        viewModel.isLoading = true
        viewModel.createAccount { success in
            DispatchQueue.main.async {
                viewModel.isLoading = false
                if success {
                    showRegisterScreen = false
                    showLoginScreen = true
                }
            }
        }
    }
}

// MARK: - Custom Components
struct CustomTextField: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .foregroundStyle(.white)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
        }
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    let icon: String
    let infoText: String
    @State private var showInfo: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                SecureField(placeholder, text: $text)
                    .foregroundStyle(.white)
                
                Button(action: { showInfo.toggle() }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
            
            if showInfo {
                Text(infoText)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
            }
        }
    }
}

struct CustomToggle: View {
    @Binding var isOn: Bool
    let text: String
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(text)
                .foregroundColor(.white)
        }
        .toggleStyle(SwitchToggleStyle(tint: .customAccent))
    }
}

// Hide Keyboard func
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
