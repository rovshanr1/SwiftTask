import SwiftUI

// MARK: - Theme Colors
struct ThemeColors {
    let accent: Color
    let background: Color
    let secondaryBackground: Color
    let text: Color
    let secondaryText: Color
    
    static let defaultTheme = ThemeColors(
        accent: Color(red: 1.00, green: 0.44, blue: 0.14),
        background: Color(red: 0.07, green: 0.07, blue: 0.07),
        secondaryBackground: Color(red: 0.12, green: 0.12, blue: 0.12),
        text: .white,
        secondaryText: Color(red: 0.69, green: 0.69, blue: 0.69)
    )
}

// MARK: - Color Extensions
extension Color {
    static let themeAccent = Color("ThemeAccent")
    static let themeBackground = Color("ThemeBackground")
    static let themeText = Color("ThemeText")
    static let themeSecondaryText = Color("ThemeSecondaryText")
    
    // Task Priority Colors
    static let taskUrgent = Color("TaskUrgent")
    static let taskHigh = Color("TaskHigh")
    static let taskMedium = Color("TaskMedium")
    static let taskLow = Color("TaskLow")
    
    // Category Colors
    static let categoryWork = Color("CategoryWork")
    static let categoryPersonal = Color("CategoryPersonal")
    static let categoryStudy = Color("CategoryStudy")
    static let categoryHealth = Color("CategoryHealth")
    
    // Status Colors
    static let statusSuccess = Color("StatusSuccess")
    static let statusError = Color("StatusError")
    static let statusWarning = Color("StatusWarning")
    static let statusInfo = Color("StatusInfo")
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [.themeAccent, .themeAccent.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let taskGradient = LinearGradient(
        colors: [.themeBackground, .themeBackground.opacity(0.9)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let focusGradient = LinearGradient(
        colors: [.purple.opacity(0.8), .blue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Shadow Styles
struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Card Styles
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.themeBackground)
            .cornerRadius(15)
            .modifier(ShadowModifier())
    }
}

// MARK: - Text Styles
extension Text {
    func titleStyle() -> some View {
        self
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.themeText)
    }
    
    func subtitleStyle() -> some View {
        self
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.themeSecondaryText)
    }
    
    func bodyStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.themeText)
    }
    
    func captionStyle() -> some View {
        self
            .font(.system(size: 14))
            .foregroundColor(.themeSecondaryText)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient.primaryGradient)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.themeBackground)
            .foregroundColor(.themeAccent)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.themeAccent, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func withShadow() -> some View {
        modifier(ShadowModifier())
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let customSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let customEase = Animation.easeInOut(duration: 0.2)
} 