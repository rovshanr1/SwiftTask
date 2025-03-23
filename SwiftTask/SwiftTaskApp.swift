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
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    HomeView(context: persistenceController.viewContext)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    if !isLaunchViewCompleted {
                        LaunchView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                     else {
                        IntroView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                }
            }
            .animation(.easeInOut, value: isLaunchViewCompleted)
            .animation(.easeInOut, value: isLoggedIn)
        }
    }
}

