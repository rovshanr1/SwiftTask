import SwiftUI

struct GuestTabBarView: View {
    let onAddTask: () -> Void
    
    // Constants
    private enum Constants {
        static let tabBarHeight: CGFloat = 70
        static let tabBarCornerRadius: CGFloat = 20
        static let addButtonSize: CGFloat = 64
        static let addButtonIconSize: CGFloat = 32
        static let horizontalPadding: CGFloat = 20
    }
    
    private var tabBarBackground: Color {
        Color(red: 0.21, green: 0.21, blue: 0.21)
            .opacity(0.8)
    }
    
    private var addButtonColor: Color {
        Color(red: 1.00, green: 0.44, blue: 0.14)
    }
    
    var body: some View {
        ZStack {

            
            // Add Button
            Button(action: onAddTask) {
                Circle()
                    .frame(width: Constants.addButtonSize, height: Constants.addButtonSize)
                    .foregroundColor(addButtonColor)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: Constants.addButtonIconSize, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: addButtonColor.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .offset(y: -30)
            .accessibilityLabel("Add New Task")
        }
    }
} 
