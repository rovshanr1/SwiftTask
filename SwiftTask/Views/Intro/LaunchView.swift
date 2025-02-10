import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    @StateObject private var viewModel = LaunchViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    // Animation properties
    private enum AnimationConstants {
        static let duration: Double = 1.0
        static let splashDuration: Double = 2.0
        static let initialScale: CGFloat = 0.5
        static let finalScale: CGFloat = 1.0
        static let initialOpacity: Double = 0.0
        static let finalOpacity: Double = 1.0
    }
    
    var body: some View {
        Group {
            if viewModel.animationCompleted {
                mainContent
            } else {
                splashContent
            }
        }
        .animation(.easeOut(duration: AnimationConstants.duration), value: viewModel.animationCompleted)
    }
    
    private var mainContent: some View {
        Group {
            if isLoggedIn {
                HomeView(context: PersistenceController.shared.viewContext)
                    .transition(.opacity)
            } else {
                IntroView()
                    .transition(.opacity)
            }
        }
    }
    
    private var splashContent: some View {
        ZStack {
            backgroundColor
            
            logoContent
                .onAppear {
                    startLaunchSequence()
                }
        }
    }
    
    private var backgroundColor: some View {
        Color(red: 0.07, green: 0.07, blue: 0.07)
            .ignoresSafeArea()
    }
    
    private var logoContent: some View {
        Image("SwigtTaskLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
            .scaleEffect(viewModel.animationCompleted ?
                        AnimationConstants.finalScale :
                        AnimationConstants.initialScale)
            .opacity(viewModel.animationCompleted ?
                    AnimationConstants.finalOpacity :
                    AnimationConstants.initialOpacity)
    }
    
    private func startLaunchSequence() {
        // Start authentication check
        viewModel.checkAuthStatus()
        
        // Update logged in state based on auth check
        isLoggedIn = viewModel.authState == .authenticated
        
        // Animate logo
        withAnimation(.easeOut(duration: AnimationConstants.duration)) {
            viewModel.animationCompleted = true
        }
        
        // Transition to main content after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.splashDuration) {
            withAnimation {
                viewModel.animationCompleted = true
            }
        }
    }
}

#Preview {
    LaunchView()
}
