//
//  MaxLiftApp.swift
//  MaxLift
//
//  Created by Justin Cohen on 11/27/25.
//

import SwiftData
import SwiftUI

@main
struct MaxLiftApp: App {
  // Configure SwiftData container with CloudKit
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      LiftEvent.self
    ])

    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false
    )

    do {
      let container = try ModelContainer(
        for: schema,
        configurations: [modelConfiguration]
      )

      // Clean up: Remove any 'template' lifts (0 weight/0 reps) that might have been created previously
      // These will now be handled statically in the ViewModel to avoid polluting history.
      Task { @MainActor in
        let context = container.mainContext

        // UI Testing Reset
        if ProcessInfo.processInfo.arguments.contains("-resetData") {
          #if targetEnvironment(simulator)
            try? context.delete(model: LiftEvent.self)
            UserDefaults.standard.removeObject(forKey: "prLookbackYears")
          #else
            // Code to run on a physical device
            print(
              "Tests are gonna fail, but we don't want to wipe our real data!"
            )
          #endif
        }
        // Cleanup templates
        // Remove any `LiftEvent` entries from the database that represent placeholder
        // or default values (0 weight and 0 reps)
        let fetchDescriptor = FetchDescriptor<LiftEvent>(
          predicate: #Predicate { $0.weight == 0 && $0.reps == 0 }
        )
        if let templateLifts = try? context.fetch(fetchDescriptor) {
          for lift in templateLifts {
            context.delete(lift)
          }
        }

        try? context.save()
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
