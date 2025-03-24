import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    @StateObject private var viewModel = LaunchViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("isLaunchViewCompleted") private var isLaunchViewCompleted: Bool = false
    @State private var isAnimating = false
    
    // Animation properties
    private enum AnimationConstants {
        static let duration: Double = 1.0
        static let splashDuration: Double = 2.5
        static let initialScale: CGFloat = 0.3
        static let finalScale: CGFloat = 1.0
        static let initialOpacity: Double = 0.0
        static let finalOpacity: Double = 1.0
    }
    
    // Environment check for testing
    @Environment(\.isTestingEnvironment) private var isTestingEnvironment
    
    private var animationDuration: Double {
        isTestingEnvironment ? 0.0 : AnimationConstants.duration
    }
    
    private var splashDuration: Double {
        isTestingEnvironment ? 0.0 : AnimationConstants.splashDuration
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Logo content
            Image("SwiftTaskLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .scaleEffect(isAnimating ? AnimationConstants.finalScale : AnimationConstants.initialScale)
                .opacity(isAnimating ? AnimationConstants.finalOpacity : AnimationConstants.initialOpacity)
                .accessibilityIdentifier("SwiftTaskLogo")
        }
        .accessibilityIdentifier("LaunchView")
        .onAppear {
            print("DEBUG: LaunchView appeared")
            AuthService.shared.checkAndResetAuthState()
            startLaunchSequence()
        }
    }
    
    private func startLaunchSequence() {
        print("DEBUG: Starting launch sequence")
        
        // Start logo animation immediately
        withAnimation(.easeOut(duration: animationDuration)) {
            isAnimating = true
        }
        
        // Perform auth check asynchronously
        Task {
            await viewModel.checkAuthStatus()
            
            // Wait for splash duration and complete launch sequence
            try? await Task.sleep(nanoseconds: UInt64(splashDuration * 1_000_000_000))
            
            withAnimation(.easeOut(duration: animationDuration)) {
                print("DEBUG: Completing launch sequence")
                isLoggedIn = viewModel.authState == .authenticated
                isLaunchViewCompleted = true
            }
        }
    }
    
}
    
 

//#Preview {
//    LaunchView()
//}
