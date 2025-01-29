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
        
        //check password
        guard password == confirmPassword else {
            isLoading = false
            errorMessage = "Password does not match"
            completion(false)
            return
        }
        
        isAccountCreated = true
        errorMessage = nil
        authService.createAccount(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result{
                case .success:
                    completion(true)
                    self?.isAccountCreated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
                
            }
            
            
            }
        }
    }
    

