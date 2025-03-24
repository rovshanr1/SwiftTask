import SwiftUI
import FirebaseAuth

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isUserLoggedIn: Bool = false
    @Published var forceLogout: Bool = false
    
    private init() {
        isUserLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userSignedOut),
            name: .userSignedOut,
            object: nil
        )
    }
    
    @objc private func userSignedOut() {
        DispatchQueue.main.async {
            self.isUserLoggedIn = false
            self.forceLogout = true
        }
    }
} 