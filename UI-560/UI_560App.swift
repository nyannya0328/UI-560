//
//  UI_560App.swift
//  UI-560
//
//  Created by nyannyan0328 on 2022/05/11.
//

import SwiftUI

@main
struct UI_560App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
