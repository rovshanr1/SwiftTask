import SwiftUI

// MARK: - Input Field
struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            
            TextField("", text: $text, prompt: Text(placeholder)
                .foregroundStyle(.gray))
                .foregroundColor(.white)
                .padding()
                .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}



// MARK: - Modern Category Button
struct ModernCategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
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
            .foregroundColor(isSelected ? .white : category.color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : Color(red: 0.21, green: 0.21, blue: 0.21))
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
            .foregroundColor(isSelected ? .white : priority.color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? priority.color : Color(red: 0.21, green: 0.21, blue: 0.21))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(priority.color, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
} 
