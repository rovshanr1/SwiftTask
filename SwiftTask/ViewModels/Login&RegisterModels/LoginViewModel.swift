//
//  LoginViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 27.01.25.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: String?
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var isSuccess: Bool = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        let authError = AuthErrorCode(_bridgedNSError: nsError)
        
        switch authError {
        case .userNotFound:
            return "❌ No account found with this email. Please check your email or create a new account."
        case .wrongPassword:
            return "❌ Incorrect password. Please try again."
        case .invalidEmail:
            return "❌ Please enter a valid email address."
        case .emailAlreadyInUse:
            return "❌ This email is already registered. Please try logging in."
        case .weakPassword:
            return "❌ Password should be at least 6 characters long."
        case .networkError:
            return "❌ Network error. Please check your internet connection."
        case .tooManyRequests:
            return "❌ Too many attempts. Please try again later."
        default:
            return "❌ \(error.localizedDescription)"
        }
    }
    
    func clearError() {
        error = nil
        isSuccess = false
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        clearError()
        
        // Input validation
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "❌ Please enter your email address."
            completion(false)
            return
        }
        
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "❌ Please enter your password."
            completion(false)
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
                          password: password.trimmingCharacters(in: .whitespacesAndNewlines)) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = self?.handleAuthError(error)
                    self?.isSuccess = false
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    completion(false)
                    return
                }
                
                if let user = result?.user, !user.isEmailVerified {
                    self?.error = "❌ Please verify your email before logging in. Check your inbox for the verification link."
                    self?.isSuccess = false
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    completion(false)
                    return
                }
                
                self?.error = "✓ Login successful!"
                self?.isSuccess = true
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                completion(true)
            }
        }
    }
    
    func resetPassword() {
        clearError()
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "❌ Please enter your email address to reset your password."
            return
        }
        
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines)) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = self?.handleAuthError(error)
                    self?.isSuccess = false
                } else {
                    self?.error = "✓ Password reset link sent! Please check your email."
                    self?.isSuccess = true
                }
            }
        }
    }
}
    


