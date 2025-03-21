import SwiftUI

class TabBarViewModel: ObservableObject {
    // Constants
    enum Constants {
        static let tabBarHeight: CGFloat = 70
        static let addButtonSize: CGFloat = 64
    }
    
    // Colors
    var tabBarBackground: Color {
        Color(red: 0.21, green: 0.21, blue: 0.21)
            .opacity(0.8)
    }
    
    var addButtonColor: Color {
        Color(red: 1.00, green: 0.44, blue: 0.14)
    }
    
    // Navigation Logic
    func handleTabSelection(navigateToHome: inout Bool, navigateToProfile: inout Bool, navigateToCalendar: inout Bool, navigateToFocus: inout Bool, selectedTab: TabType) {
        // Önce tüm navigasyon değerlerini false yap
        navigateToHome = false
        navigateToProfile = false
        navigateToCalendar = false
        navigateToFocus = false
        
        // Seçilen tab'a göre ilgili navigasyonu true yap
        switch selectedTab {
        case .home:
            navigateToHome = true
        case .focus:
            navigateToFocus = true
        case .calendar:
            navigateToCalendar = true
        case .profile:
            navigateToProfile = true
        }
    }
}

// Tab Types
enum TabType {
    case home
    case focus
    case calendar
    case profile
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .focus: return "timer"
        case .calendar: return "calendar"
        case .profile: return "person"
        }
    }
} 
