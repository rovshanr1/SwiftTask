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
    
    var body: some View {
        ZStack {
            backgroundColor
            
            logoContent
                .scaleEffect(isAnimating ? AnimationConstants.finalScale : AnimationConstants.initialScale)
                .opacity(isAnimating ? AnimationConstants.finalOpacity : AnimationConstants.initialOpacity)
                .onAppear {
                    startLaunchSequence()
                }
        }
        .accessibilityIdentifier("LaunchView")
        .onAppear {
            print("LaunchView appeared")
        }
    }
    
    private var backgroundColor: some View {
        Color(red: 0.07, green: 0.07, blue: 0.07)
            .ignoresSafeArea()
    }
    
    private var logoContent: some View {
        Image("SwiftTaskLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
            .accessibilityIdentifier("SwiftTaskLogo")
    }
    
    private func startLaunchSequence() {
        // Start authentication check
        viewModel.checkAuthStatus()
        
        // Update logged in state based on auth check
        isLoggedIn = viewModel.authState == .authenticated
        
        // Animate logo appearance
        withAnimation(.easeOut(duration: AnimationConstants.duration)) {
            isAnimating = true
        }
        
        // Wait for animation and then complete launch view
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.splashDuration) {
            withAnimation(.easeOut(duration: AnimationConstants.duration)) {
                isLaunchViewCompleted = true
            }
        }
    }
}

#Preview {
    LaunchView()
}
