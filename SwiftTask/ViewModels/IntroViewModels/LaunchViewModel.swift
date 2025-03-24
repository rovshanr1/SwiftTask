//
//  LaunchViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 10.02.25.
//

import Foundation
import FirebaseAuth

@MainActor
final class LaunchViewModel: ObservableObject, Sendable {
    @Published var authState: AuthState = .initializing
    @Published var animationCompleted = false
    
    enum AuthState: Equatable {
        case initializing
        case authenticated
        case unauthenticated
        case error(Error)
        
        static func == (lhs: AuthState, rhs: AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.initializing, .initializing):
                return true
            case (.authenticated, .authenticated):
                return true
            case (.unauthenticated, .unauthenticated):
                return true
            case (.error, .error):
                // Note: We consider all errors equal for comparison purposes
                return true
            default:
                return false
            }
        }
    }
    
    func checkAuthStatus() async {
        // Add a small delay to ensure Firebase is properly initialized
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Since we're @MainActor, we can directly update state
        if let currentUser = Auth.auth().currentUser {
            print("DEBUG: User is authenticated: \(currentUser.uid)")
            authState = .authenticated
        } else {
            print("DEBUG: User is not authenticated")
            authState = .unauthenticated
        }
    }
}
