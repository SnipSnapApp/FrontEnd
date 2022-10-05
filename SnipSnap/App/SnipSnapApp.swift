/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

import SwiftUI

@main
struct SnipSnapApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
