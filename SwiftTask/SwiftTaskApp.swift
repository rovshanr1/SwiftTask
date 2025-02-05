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
       
        var body: some Scene {
            WindowGroup {
                LaunchView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }

