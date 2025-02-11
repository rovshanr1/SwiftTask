import SwiftUI

struct ResetPasswordView: View {
    @Binding var yourEmail: String
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var isKeyboardActive: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.headline)
                .foregroundColor(.white)
            
            Divider().background(Color.gray)
                .padding(8)
            
            TextField("Please enter your email", text: $yourEmail)
                .padding()
                .frame(maxWidth: .infinity)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .focused($isKeyboardActive)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            HStack(spacing: 20) {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                .frame(width: 153, height: 48)
                
                Button(action: {
                    viewModel.email = yourEmail
                    viewModel.resetPassword()
                }) {
                    Text("Send Reset Link")
                        .foregroundStyle(.white)
                        .frame(width: 153, height: 48)
                        .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .cornerRadius(5)
                }
            }
            .padding()
        }
        .cornerRadius(15)
        .padding()
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ResetPasswordView(yourEmail: .constant(""), isPresented: .constant(true), viewModel: LoginViewModel())
}
