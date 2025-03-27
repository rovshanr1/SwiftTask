import SwiftUI

// MARK: - Input Field
struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(themeManager.currentTheme.secondaryText)
            
            TextField("", text: $text, prompt: Text(placeholder)
                .foregroundStyle(themeManager.currentTheme.secondaryText))
                .foregroundStyle(themeManager.currentTheme.text)
                .padding()
                .background(themeManager.currentTheme.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.text.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

// MARK: - Modern Category Button
struct ModernCategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                Text(category.rawValue)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .foregroundStyle(isSelected ? themeManager.currentTheme.text : category.color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : themeManager.currentTheme.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// MARK: - Modern Priority Button
struct ModernPriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? priority.color : Color.clear)
                    .frame(width: 12, height: 12)
                
                Text(priority.title)
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .foregroundStyle(isSelected ? themeManager.currentTheme.text : priority.color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? priority.color : themeManager.currentTheme.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(priority.color, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
} 
