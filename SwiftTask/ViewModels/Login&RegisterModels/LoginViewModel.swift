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
    
    
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    completion(false)
                    return
                }
                
                if let user = result?.user, !user.isEmailVerified {
                    self?.error = "Please verify your email before logging in."
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
}
    


