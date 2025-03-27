//
//  SwiftTaskApp.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 25.01.25.
//

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Auth durumunu uygulama başlarken kontrol et
        AuthService.shared.checkAndResetAuthState()
        
        // Notification delegate'i ayarla
        UNUserNotificationCenter.current().delegate = self
        
        // Bildirim izinlerini iste
        requestNotificationPermissions()
        
        return true
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // Bildirim geldiğinde uygulama açıkken göster
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Bildirimi banner, ses ve rozet olarak göster
        completionHandler([.banner, .sound, .badge])
    }
    
    // Bildirime tıklandığında işle
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Bildirim tipine göre işlem yap
        if response.notification.request.identifier == "dailyReminder" {
            NotificationCenter.default.post(name: .dailyReminderTapped, object: nil)
        } else {
            // Görev bildirimi için taskId'yi gönder
            if let taskId = userInfo["taskId"] as? String {
                NotificationCenter.default.post(
                    name: .taskReminderTapped,
                    object: nil,
                    userInfo: ["taskId": taskId]
                )
            }
        }
        
        completionHandler()
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

