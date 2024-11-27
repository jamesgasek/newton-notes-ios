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
            fatalError("Could not create ModelContainer: \(error)")
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
