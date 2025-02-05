import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var isMainScreenActive: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        if isMainScreenActive {
            if isLoggedIn {
                HomeView(context: PersistenceController.shared.viewContext)
            } else {
                IntroView()
            }
        } else {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    Image("appIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .onAppear {
                            checkUserStatus()
                            withAnimation(.easeOut(duration: 1.0)) {
                                logoScale = 1.0
                                logoOpacity = 1.0
                            }
                        }
                }
            }
        }
    }
    
    private func checkUserStatus() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isMainScreenActive = true
            }
        }
    }
}

#Preview {
    LaunchView()
}
