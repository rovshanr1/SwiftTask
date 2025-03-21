import SwiftUI

struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(icon.capitalized)
    }
} 