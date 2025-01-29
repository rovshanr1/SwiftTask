//
//  AuthServices.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 27.01.25.
//
import Foundation
import FirebaseAuth
//import GoogleSignIn
//import GoogleSignInSwift
//import AuthenticationServices

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func createAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
//    func loginWithGoogle(completion: @escaping (Result<Void, Error>) -> Void)
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func createAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
//
//    func loginWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
//        //
//    }
}
