import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    let themes: [String: ThemeColors] = [
        "Default": ThemeColors.defaultTheme,
        "Ocean": ThemeColors(
            accent: Color(red: 0.0, green: 0.7, blue: 0.9),
            background: Color(red: 0.05, green: 0.1, blue: 0.15),
            secondaryBackground: Color(red: 0.1, green: 0.15, blue: 0.2),
            text: .white,
            secondaryText: Color(red: 0.7, green: 0.8, blue: 0.9)
        ),
        "Forest": ThemeColors(
            accent: Color(red: 0.2, green: 0.8, blue: 0.4),
            background: Color(red: 0.05, green: 0.15, blue: 0.1),
            secondaryBackground: Color(red: 0.1, green: 0.2, blue: 0.15),
            text: .white,
            secondaryText: Color(red: 0.7, green: 0.9, blue: 0.8)
        ),
        "Sunset": ThemeColors(
            accent: Color(red: 1.0, green: 0.6, blue: 0.2),
            background: Color(red: 0.15, green: 0.1, blue: 0.15),
            secondaryBackground: Color(red: 0.2, green: 0.15, blue: 0.2),
            text: .white,
            secondaryText: Color(red: 0.9, green: 0.8, blue: 0.7)
        )
    ]
    
    @Published private(set) var currentTheme: ThemeColors
    @AppStorage("selectedTheme") private(set) var selectedTheme: String = "Default"
    
    private init() {
        let initialTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Default"
        self.currentTheme = themes[initialTheme] ?? ThemeColors.defaultTheme
        self.selectedTheme = initialTheme
    }
    
    func setTheme(_ themeName: String) {
        selectedTheme = themeName
        if let theme = themes[themeName] {
            currentTheme = theme
            updateSystemColors(with: theme)
        }
    }
    
    private func updateSystemColors(with theme: ThemeColors) {
        // Update color assets or system-wide colors
        UserDefaults.standard.set(theme.accent.cgColor?.components, forKey: "ThemeAccent")
        UserDefaults.standard.set(theme.background.cgColor?.components, forKey: "ThemeBackground")
        UserDefaults.standard.set(theme.secondaryBackground.cgColor?.components, forKey: "ThemeSecondaryBackground")
        UserDefaults.standard.set(theme.text.cgColor?.components, forKey: "ThemeText")
        UserDefaults.standard.set(theme.secondaryText.cgColor?.components, forKey: "ThemeSecondaryText")
        
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
} 