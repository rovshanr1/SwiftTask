import SwiftUI

struct LoginView: View {
    @StateObject  var viewModel = LoginViewModel()
    @Binding var showLoginScreen: Bool
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case email
        case password
    }
    
    @State private var navigationToHome = false
    @State private var navigateToResetPassword = false
    
    // Define the global gradient once
        let globalGradient = LinearGradient(
            gradient: Gradient(colors: [Color(red: 1.00, green: 0.44, blue: 0.14), Color(red: 0.29, green: 0.29, blue: 0.51)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        VStack(alignment: .leading, spacing: 10) {
                            // Email
                            Text("Email")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            TextField("Enter your email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                                .padding()
                                .foregroundStyle(.white)
                                .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                                .cornerRadius(12)
                                .focused($focusedField, equals: .email)
                            
                            // Password
                            Text("Password")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            SecureField("Enter your password", text: $viewModel.password)
                                .textContentType(.password)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                    if !viewModel.email.isEmpty && !viewModel.password.isEmpty {
                                        viewModel.login { success in
                                            if success {
                                                navigationToHome = true
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .foregroundStyle(.white)
                                .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                                .cornerRadius(12)
                                .focused($focusedField, equals: .password)
                            
                            if let errorMessage = viewModel.error {
                                Text(errorMessage)
                                    .foregroundColor(viewModel.isSuccess ? .green : .red)
                                    .font(.system(size: 14))
                                    .padding(.top, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: errorMessage)
                            }
                        }
                        
                        VStack(spacing: 20) {
                            // Login Button
                            Button(action: {
                                if viewModel.email.isEmpty || viewModel.password.isEmpty {
                                    viewModel.error = "❌ Email and password cannot be empty."
                                } else {
                                    viewModel.login { success in
                                        DispatchQueue.main.async {
                                            if success {
                                                navigationToHome = true
                                            }
                                        }
                                    }
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .foregroundStyle(.white)
                                            .scaleEffect(1.0)
                                    } else {
                                        Text("Login")
                                            .font(.headline)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(.white)
                                .background(globalGradient)
                                .cornerRadius(10)
                            }
                            .disabled(viewModel.isLoading)
                            
                            Button(action: {
                                navigateToResetPassword = true
                            }){
                                Text("Forgot Password?")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .underline()
                            }
                            .sheet(isPresented: $navigateToResetPassword){
                                ResetPasswordView(yourEmail: $viewModel.email, isPresented: $navigateToResetPassword, viewModel: viewModel)
                            }
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showLoginScreen = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal){
                    Text("Login")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .bold))
                }
            
            }
            .navigationDestination(isPresented: $navigationToHome) {
                    HomeView(context: PersistenceController.shared.viewContext)}

        }
    }
}
