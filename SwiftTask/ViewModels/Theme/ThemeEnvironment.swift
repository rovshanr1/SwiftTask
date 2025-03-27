import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = ThemeColors.defaultTheme
}

extension EnvironmentValues {
    var theme: ThemeColors {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    func theme(_ theme: ThemeColors) -> some View {
        environment(\.theme, theme)
    }
} 