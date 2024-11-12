//
//  Newton_Notes_IOSApp.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/1/24.
//

import SwiftUI
import SwiftData
//
//@main
//struct WorkoutTrackerApp: App {
//    let container: ModelContainer
//    @StateObject private var workoutManager = WorkoutManager()
//    
//    init() {
//        do {
//            let config = ModelConfiguration(isStoredInMemoryOnly: false)
//            container = try ModelContainer(
//                for: Routine.self, Exercise.self, ExerciseTemplate.self, ExerciseSet.self,
//                configurations: config
//            )
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView().environment(workoutManager)
//
//        }
//        .modelContainer(container)
//    }
//}
@main
struct WorkoutTrackerApp: App {
    let container: ModelContainer
    @State private var workoutManager = WorkoutManager()  // Change to @State
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(
                for: Routine.self, Exercise.self, ExerciseTemplate.self, ExerciseSet.self, AnalyticsLog.self,
                configurations: config
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView()
                .environment(workoutManager)  // This stays the same
        }
        .modelContainer(container)
    }
}
