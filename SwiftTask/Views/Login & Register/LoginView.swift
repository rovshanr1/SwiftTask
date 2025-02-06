import SwiftUI

struct LoginView: View {
    @StateObject  var viewModel = LoginViewModel()
    @Binding var showLoginScreen: Bool
    @FocusState private var isKeyboardActive: Bool
    @State private var navigationToHome = false
    
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
                        // Title
                        Text("Login")
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
                                .focused($isKeyboardActive) // Track keyboard status
                            
                            // Password
                            Text("Password")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            SecureField("Enter your Password", text: $viewModel.password)
                                .padding()
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isKeyboardActive)
                            
                            if let errorMessage = viewModel.error {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                    .padding(.top, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                        VStack(spacing: 20) {
                            // Login Button
                            Button(action: {
                                if viewModel.email.isEmpty || viewModel.password.isEmpty {
                                    viewModel.error = "Email and password cannot be empty."
                                } else {
                                    viewModel.login { success in
                                        if success {
                                            DispatchQueue.main.async {
                                                navigationToHome = true
                                            }
                                           
                                        }
                                    }
                                }
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .foregroundStyle(.white)
                                } else {
                                    Text("Login")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundStyle(.white)
                                        .background(globalGradient)
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
                                                .stroke(globalGradient, lineWidth: 2)
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
                                                    .stroke(globalGradient, lineWidth: 2)
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
                    hideKeyboard() 
                }
            }
            .navigationBarBackButtonHidden(true)
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
            
            }
            .navigationDestination(isPresented: $navigationToHome) {
                    HomeView(context: PersistenceController.shared.viewContext)}

        }
    }
}

//NavigationLink(destination: HomeView(context: PersistenceController.shared.viewContext), isActive: $navigationToHome){
//    EmptyView()
//}

#Preview {
    LoginView(showLoginScreen: .constant(true))
}
