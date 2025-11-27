//
//  MaxLiftApp.swift
//  MaxLift
//
//  Created by Justin Cohen on 11/27/25.
//

import SwiftUI
import SwiftData

@main
struct MaxLiftApp: App {
    // Configure SwiftData container with CloudKit
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LiftEvent.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Clean up: Remove any 'template' lifts (0 weight/0 reps) that might have been created previously
            // These will now be handled statically in the ViewModel to avoid polluting history.
            Task { @MainActor in
                let fetchDescriptor = FetchDescriptor<LiftEvent>(predicate: #Predicate { $0.weight == 0 && $0.reps == 0 })
                if let templateLifts = try? container.mainContext.fetch(fetchDescriptor) {
                    for lift in templateLifts {
                        container.mainContext.delete(lift)
                    }
                    if !templateLifts.isEmpty {
                        try? container.mainContext.save()
                    }
                }
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
