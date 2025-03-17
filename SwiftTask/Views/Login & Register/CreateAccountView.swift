
import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var loginviewModel: LoginViewModel
    @StateObject private var viewModel = CreateAccountViewModel()
    @Binding var showRegisterScreen: Bool
    @Binding var showLoginScreen: Bool // Yeni eklenen binding
    @FocusState private var isKeyboardActive: Bool
    
    let globalGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 1.00, green: 0.44, blue: 0.14), Color(red: 0.29, green: 0.29, blue: 0.51)]),
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Create Account")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Username")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            TextField("Enter your Username", text: $viewModel.username)
                                .padding()
                                .autocapitalization(.none)
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isKeyboardActive)
                            
                            Text("Email")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            TextField("Enter your Email", text: $viewModel.email)
                                .padding()
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isKeyboardActive)
                            
                            PasswordFieldWithInfo(
                                text: $viewModel.password,
                                title: "Password",
                                placeholder: "Enter your Password",
                                infoText: "Password must be at least 8 characters long and contain uppercase, lowercase, number, and special character."
                            )
                            
                            PasswordFieldWithInfo(
                                text: $viewModel.confirmPassword,
                                title: "Confirm Password",
                                placeholder: "Confirm your Password",
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
                        
                        VStack(spacing: 20) {
                            Button(action: {
                                guard viewModel.isPrivacyAccepted && viewModel.isConditionsAccepted else {
                                    viewModel.errorMessage = "Please accept Privacy Policy and Terms & Conditions"
                                    return
                                }
                                
                                if viewModel.username.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty {
                                    viewModel.errorMessage = "All fields are required."
                                    return
                                }
                                
                                if viewModel.password != viewModel.confirmPassword {
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
                            }) {
                                ZStack{
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .foregroundStyle(.white)
                                            .padding(.horizontal)
                                        
                                    } else {
                                        Text("Register")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .foregroundStyle(.white)
                                            .background(globalGradient)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 10) {
                            Toggle(isOn: $viewModel.isConditionsAccepted) {
                                HStack {
                                    Text("I agree to the")
                                        .foregroundColor(.white)
                                    Button(action: {}) {
                                        Text("Terms and Conditions")
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            
                            Toggle(isOn: $viewModel.isPrivacyAccepted) {
                                HStack {
                                    Text("I agree to the")
                                        .foregroundColor(.white)
                                    Button(action: {}) {
                                        Text("Privacy Policy")
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                        }
                        
                        // Yeni düzenlenmiş buton
                        Button(action: {
                            showLoginScreen = true    // LoginView'ı aç
                        }) {
                            Text("Already have an account? Log in")
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .navigationDestination(isPresented: $showLoginScreen){
                            LoginView(showLoginScreen: $showLoginScreen)
                        }
                        .padding(.top, 10)
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
                    Button(action: {
                        showRegisterScreen = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// PasswordFieldWithInfo ve hideKeyboard extension değişmeden kalacak.
struct PasswordFieldWithInfo: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    let infoText: String
    @State private var showInfo: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            ZStack(alignment: .trailing) {
                SecureField(placeholder, text: $text)
                    .padding()
                    .foregroundStyle(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                Button {
                    showInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                }
                .padding(.trailing, 8)
            }
            
            if showInfo {
                Text(infoText)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .cornerRadius(8)
            }
        }
    }
}

// Hide Keyboard func
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
