//
//  CreateAccountViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 29.01.25.
//

import Foundation
import FirebaseAuth

class CreateAccountViewModel: ObservableObject {
    @Published var username: String = ""  // Kullanıcı adı alanı eklendi
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
        
        // **1. Boş Alan Kontrolü**
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            completion(false)
            return
        }

        // **2. Şifre Eşleşme Kontrolü**
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            completion(false)
            return
        }

        isLoading = true  // İşlem başladığında yükleme durumu aktif hale getirildi
        
        // **3. Firebase Hesap Oluşturma**
        authService.createAccount(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false  // İşlem bittiğinde yükleme durumu kaldırıldı
                
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
    
}
