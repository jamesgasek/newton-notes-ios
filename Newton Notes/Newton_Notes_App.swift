import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit
import ActivityKit

@main
struct Newton_Notes_App: App {
    @StateObject private var themeManager = ThemeManager()
    let container: ModelContainer
    @State private var workoutManager = WorkoutManager()
    
    init() {
        do {
            let schema = Schema([
                Routine.self,
                Exercise.self,
                ExerciseTemplate.self,
                ExerciseSet.self,
                AnalyticsLog.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            
            // Check Live Activity support
            Task {
                let info = ActivityAuthorizationInfo()
                if info.areActivitiesEnabled {
                    print("Live Activities are enabled")
                }
            }
        } catch {
            print("Error creating ModelContainer: \(error). Clearing data and creating fresh database.")
            
            // Clear the existing database
            let fileManager = FileManager.default
            if let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let databaseURL = url.appendingPathComponent("default.store")
                try? fileManager.removeItem(at: databaseURL)
            }
            
            // Create a fresh database
            do {
                let schema = Schema([
                    Routine.self,
                    Exercise.self,
                    ExerciseTemplate.self,
                    ExerciseSet.self,
                    AnalyticsLog.self
                ])
                
                let modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
                
                container = try ModelContainer(
                    for: schema,
                    configurations: modelConfiguration
                )
            } catch {
                fatalError("Could not create fresh ModelContainer: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView()
                .environment(workoutManager)
                .environmentObject(themeManager)
                .onAppear {
                    themeManager.applyTheme()
                }
        }
        .modelContainer(container)
    }
}