//
//  ResidenceFinderApp.swift
//  ResidenceFinder
//
//  Created by Jason Yoon on 2022-03-20.
//

import SwiftUI

@main
struct ResidenceFinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
