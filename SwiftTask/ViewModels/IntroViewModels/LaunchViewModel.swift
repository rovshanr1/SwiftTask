//
//  LaunchViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 10.02.25.
//

import Foundation
import FirebaseAuth
class LaunchViewModel: ObservableObject {
    @Published var authState: AuthState = .initializing
    @Published var animationCompleted = false
    
    enum AuthState {
        case initializing
        case authenticated
        case unauthenticated
    }
    
    func checkAuthStatus() {
        if Auth.auth().currentUser != nil {
            authState = .authenticated
        } else {
            authState = .unauthenticated
        }
    }
}
