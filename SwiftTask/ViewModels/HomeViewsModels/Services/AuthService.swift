//
//  AuthServiceProtocol.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 10.02.25.
//
import FirebaseAuth
import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func createAccount(username: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user, !user.isEmailVerified {
                completion(.failure(NSError(domain: "AuthError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Please verify your email before logging in."])))
                return
            }
            
            completion(.success(()))
        }
    }
    
    func createAccount(username: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // First validate inputs
        guard !username.isEmpty else {
            completion(.failure(NSError(domain: "AuthError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Username cannot be empty"])))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard self != nil else {
                completion(.failure(NSError(domain: "AuthError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Internal error occurred"])))
                return
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "User creation failed"])))
                return
            }
            
            // Send verification email
            user.sendEmailVerification { error in
                if let error = error {
                    print("Error sending email verification: \(error.localizedDescription)")
                }
            }
            
            func resetPassword(email: String) {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        print("Password reset error:\(error.localizedDescription)")
                    } else {
                        print("A password reset email has been sent.")
                    }
                }
            }
            
            // Create profile with provided username
            let profile = ProfileModel(
                userName: username,
                taskLeft: 0,
                taskDone: 0,
                email: email,
                timestamp: Date()
            )
            
            // Save user profile to Firestore
            UserService.shared.saveUserProfile(userID: user.uid, profile: profile) { error in
                if let error = error {
                    // If profile creation fails, delete the created auth user
                    user.delete { _ in }
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
