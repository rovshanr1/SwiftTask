//
//  CreateAccountVievModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 29.01.25.
//

import Foundation
import FirebaseAuth

class CreateAccountViewModel: ObservableObject{
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isAccountCreated: Bool = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared){
        self.authService = authService
    }
    func createAccount(completion: @escaping (Bool) -> Void){
        isAccountCreated = true
        errorMessage = nil
        authService.createAccount(email: email, password: password) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2)  {
                if self?.password != self?.confirmPassword {
                    self?.errorMessage = "Passwords do not match"
                    self?.isLoading = false
                    completion(false)
                    return
                }
                
                self?.isLoading = false 
                            completion(true)
            }
            
            
        }
    }
}


