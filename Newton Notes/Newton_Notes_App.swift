//
//  Newton_Notes_IOSApp.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/1/24.
//

import SwiftUI
import SwiftData
import UserNotifications
import BackgroundTasks

// In your SceneDelegate or App
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jamesgasek.newtonnotes.timerprocessing", using: nil) { task in
        // Handle the background task
        task.setTaskCompleted(success: true)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}

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
