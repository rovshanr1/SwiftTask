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
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .white : color)
                }
                
                Text(category.rawValue)
                    .foregroundColor(isSelected ? .white : color)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(isSelected ? color : color.opacity(0.2))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
    }
} 