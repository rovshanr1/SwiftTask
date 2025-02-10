import SwiftUI

struct CreateAccountView: View {
    @StateObject private var viewModel = CreateAccountViewModel()
    @Binding var showRegisterScreen: Bool
    @FocusState private var isKeyboardActive: Bool
    @State private var navigateToLogin = false
    @State private var navigateToPrivacyPolicy = false
    @State private var navigateToTermsOfService = false
    
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
                        Text("Register")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .padding(.bottom, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
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

                            Text("Password")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                            SecureField("Enter your Password", text: $viewModel.password)
                                .padding()
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isKeyboardActive)

                            Text("Confirm Password")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                            SecureField("Confirm your Password", text: $viewModel.confirmPassword)
                                .padding()
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isKeyboardActive)

                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                    .padding(.top, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                        VStack(spacing: 10){
                            Toggle(isOn: $viewModel.isConditionsAccepted) {
                                HStack {
                                    Text("I agree to the")
                                        .foregroundColor(.white)
                                    Button(action: {
                                        navigateToTermsOfService  = true
                                    }) {
                                        Text("Terms and Conditions")
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange)) // Toggle color
                            .navigationDestination(isPresented: $navigateToTermsOfService ){
                                TermsandConditionsView()
                            }
                            // Privacy Policy Onayı
                            Toggle(isOn: $viewModel.isPrivacyAccepted) {
                                HStack {
                                    Text("I agree to the")
                                        .foregroundColor(.white)
                                    Button(action: {
                                        navigateToPrivacyPolicy = true
                                    }) {
                                        Text("Privacy Policy")
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange)) //Toggle color
                            .navigationDestination(isPresented: $navigateToPrivacyPolicy){
                                PrivacyPolicyView()
                            }
                        }

                        VStack(spacing: 20) {
                            Button(action: {
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
                                            viewModel.errorMessage = "Registration successful. Please verify your email."
                                            navigateToLogin = true
                                        } else {
                                            viewModel.errorMessage = "Registration failed. Try again."
                                        }
                                    }
                                }
                            }) {
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
                                        .opacity(viewModel.isPrivacyAccepted ? 1.0 : 0.5) // Button active/passive status
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(!viewModel.isPrivacyAccepted || viewModel.isLoading) // The button will remain inactive
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationBarBackButtonHidden(true)
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


// Hide Keyboard func
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
