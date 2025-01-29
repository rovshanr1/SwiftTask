import SwiftUI

struct CreateAccountView: View {
    @StateObject private var viewModel = CreateAccountViewModel()
    @Binding var showRegisterScreen: Bool
    @FocusState private var isKeyboardActive: Bool // Monitor keyboard status

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer() // Prevents content scrolling when the keyboard is opened
                }
                
                ScrollView { // Allows content to scroll when keyboard is opened
                    VStack(alignment: .leading, spacing: 20) {
                        // Başlık
                        Text("Register")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .padding(.bottom, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            // Username
                            Text("Username")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            TextField("Enter your Username", text: $viewModel.email)
                                .padding()
                                .autocapitalization(.none)
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isKeyboardActive) // Monitor keyboard status
                            
                            // Password
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
                            
                            // Confirm Password
                            Text("Confirm Password")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                            SecureField("Confirm your Password", text: $viewModel.confirmPassword)
                                .padding()
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(viewModel.password == viewModel.confirmPassword ? Color.gray : Color.red, lineWidth: 2)
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
                        
                        VStack(spacing: 20) {
                            // Register Button
                            Button(action: {
                                if viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty {
                                    viewModel.errorMessage = "All fields are required"
                                } else {
                                    viewModel.createAccount { success in
                                        if success {
                                            print("Login successful!")
                                        }
                                    }
                                }
                            }) {
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
                                        .background(Color(red: 0.53, green: 0.53, blue: 0.91))
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(viewModel.isLoading)
                            
                            // OR Divider
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.gray)
                                Text("or")
                                    .foregroundStyle(.gray)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.gray)
                            }
                            
                            // Google & Apple Login Buttons
                            VStack(spacing: 20) {
                                Button(action: {
                                    print("Google Account logged in")
                                }) {
                                    Text("Login with Google")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundStyle(.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(red: 0.53, green: 0.53, blue: 0.91), lineWidth: 2)
                                        )
                                }
                                
                                Button(action: {
                                    print("Apple Account logged in")
                                }) {
                                    HStack {
                                        Text("Login with Apple")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .foregroundStyle(.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color(red: 0.53, green: 0.53, blue: 0.91), lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    hideKeyboard() // Close keyboard when screen is touched
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

#Preview {
    CreateAccountView(showRegisterScreen: .constant(true))
}
