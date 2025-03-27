import SwiftUI

struct ResetPasswordView: View {
    @Binding var yourEmail: String
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var isKeyboardActive: Bool
    
    // Global gradient tanımı
    private let globalGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 1.00, green: 0.44, blue: 0.14), Color(red: 0.29, green: 0.29, blue: 0.51)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 8) {
                    Text("Reset Password")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal, -24)
                }
                
                // Description
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Email Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    TextField("Enter your email", text: $yourEmail)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.continue)
                        .onSubmit {
                            if !yourEmail.isEmpty {
                                viewModel.email = yourEmail
                                viewModel.resetPassword()
                            }
                        }
                        .foregroundStyle(.white)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(12)
                        .focused($isKeyboardActive)
                }
                .padding(.top, 8)
                
                // Error Message
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(error.contains("sent") ? .green : .red)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        if !yourEmail.isEmpty {
                            viewModel.email = yourEmail
                            viewModel.resetPassword()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .foregroundStyle(.white)
                        } else {
                            Text("Send Reset Link")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(globalGradient)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(viewModel.isLoading || yourEmail.isEmpty)
                }
            }
            .padding(24)
        }
        .presentationDetents([.height(400)])
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    ResetPasswordView(yourEmail: .constant(""), isPresented: .constant(true), viewModel: LoginViewModel())
}
