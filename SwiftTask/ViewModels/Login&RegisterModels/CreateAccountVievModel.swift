//
//  CreateAccountViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 29.01.25.
//

import Foundation
import FirebaseAuth

class CreateAccountViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isAccountCreated: Bool = false
    @Published var isPrivacyAccepted: Bool = false
    @Published var isConditionsAccepted: Bool = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func createAccount(completion: @escaping (Bool) -> Void) {
        errorMessage = nil
        
        // Validate inputs
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            completion(false)
            return
        }
        
        // Validate privacy and conditions
        guard isPrivacyAccepted && isConditionsAccepted else {
            errorMessage = "Please accept privacy policy and terms & conditions."
            completion(false)
            return
        }
        
        // Validate password
        guard isPasswordValid(password) else {
            errorMessage = "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character."
            completion(false)
            return
        }
        
        // Check password match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            completion(false)
            return
        }
        
        isLoading = true
        
        // Create account with username
        authService.createAccount(username: username, email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.isAccountCreated = true
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}
