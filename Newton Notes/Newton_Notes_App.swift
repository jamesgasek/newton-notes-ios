//
//  Newton_Notes_IOSApp.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/1/24.
//

import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(
                for: Routine.self, Exercise.self, ExerciseTemplate.self, ExerciseSet.self,
                configurations: config
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
