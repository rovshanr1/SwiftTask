//
//  SwiftTaskApp.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 25.01.25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Auth durumunu uygulama başlarken kontrol et
        AuthService.shared.checkAndResetAuthState()
        return true
    }
}

@main
struct SwiftTaskApp: App {
    let persistenceController = PersistenceController.shared
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // State variables to control view flow
    @AppStorage("isLaunchViewCompleted") private var isLaunchViewCompleted: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    // App state
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn && !appState.forceLogout {
                    HomeView(context: persistenceController.viewContext)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .onChange(of: appState.forceLogout) { _, newValue in
                            if newValue {
                                isLoggedIn = false
                            }
                        }
                } else {
                    if !isLaunchViewCompleted {
                        LaunchView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    } else {
                        IntroView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                }
            }
            .animation(.easeInOut, value: isLaunchViewCompleted)
            .animation(.easeInOut, value: isLoggedIn)
            .animation(.easeInOut, value: appState.forceLogout)
        }
    }
}

