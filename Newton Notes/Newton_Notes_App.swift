import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit
import ActivityKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Configure notification categories
        let timerCategory = UNNotificationCategory(
            identifier: "TIMER_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        let completeCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([timerCategory, completeCategory])
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct Newton_Notes_App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // Request Live Activity permissions if needed
        Task {
            let info = ActivityAuthorizationInfo()
            if info.areActivitiesEnabled {
                // Live Activities are supported on this device
                print("Live Activities are enabled on this device")
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
