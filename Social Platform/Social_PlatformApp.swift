//
//  Social_PlatformApp.swift
//  Social Platform
//
//  Created by Abdoulie Jallow on 12/30/25.
//

import SwiftUI
import CoreData

@main
struct Social_PlatformApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
