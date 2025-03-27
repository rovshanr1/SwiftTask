import SwiftUI

struct AppThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("App Theme")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(themeManager.currentTheme.text)
                    
                    Divider()
                        .background(themeManager.currentTheme.secondaryText)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Array(themeManager.themes.keys.sorted()), id: \.self) { theme in
                                ThemeOptionView(
                                    theme: theme,
                                    isSelected: themeManager.selectedTheme == theme,
                                    colors: themeManager.themes[theme]!,
                                    currentTheme: themeManager.currentTheme
                                ) {
                                    withAnimation {
                                        themeManager.setTheme(theme)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.accent)
                            .foregroundColor(themeManager.currentTheme.text)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
        }
    }
}

struct ThemeOptionView: View {
    let theme: String
    let isSelected: Bool
    let colors: ThemeColors
    let currentTheme: ThemeColors
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(theme)
                        .font(.headline)
                        .foregroundStyle(currentTheme.text)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(colors.accent)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(colors.background)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(colors.secondaryBackground)
                            .frame(width: 20, height: 20)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(colors.accent)
                        .font(.title2)
                }
            }
            .padding()
            .background(colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? colors.accent : .clear, lineWidth: 2)
            )
        }
    }
} 