import SwiftUI

struct CategoryButton<T: RawRepresentable & CaseIterable>: View where T.RawValue == String {
    let category: T
    let isSelected: Bool
    let action: () -> Void
    let color: Color
    let icon: String?
    
    init(
        category: T,
        isSelected: Bool,
        color: Color,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.category = category
        self.isSelected = isSelected
        self.color = color
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .white : color)
                        .font(.system(size: 12))
                }
                
                Text(category.rawValue)
                    .foregroundColor(isSelected ? .white : color)
                    .font(.system(size: 12))
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(height: 32)
            .background(isSelected ? color : color.opacity(0.2))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
    }
} 