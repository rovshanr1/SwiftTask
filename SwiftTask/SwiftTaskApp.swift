//
//  SwiftTaskApp.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 25.01.25.
//

import SwiftUI

@main
struct SwiftTaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
