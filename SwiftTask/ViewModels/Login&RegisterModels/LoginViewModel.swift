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
    
    func login(completion: @escaping (Bool) -> Void){
        isLoading = true
        error = nil
        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    completion(true)
                    self?.isLoggedIn = true
                case .failure(let error):
                   self?.error = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
    


