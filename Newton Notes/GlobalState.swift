////
////  GlobalState.swift
////  Newton Notes
////
////  Created by James Gasek on 11/7/24.
////

import Foundation
import UIKit
import UserNotifications
import BackgroundTasks

//@Observable class WorkoutManager {
////    var currentRoutine: Routine?
////    var completedSets = Set<String>()
////    var timeRemaining: Int = 0 {
////        didSet {
////            updateNotification()
////        }
////    }
////    var activeExercise: Exercise?
////    var activeSetIndex: Int?
////    var isWorkoutInProgress: Bool = false
////    
////    private var dispatchTimer: DispatchSourceTimer?
////    
////    init() {
////        // Request notification permissions when initializing
////        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
////            if granted {
////                print("Notification permission granted")
////            }
////        }
////    }
////    
////    private func updateNotification() {
////        let notificationCenter = UNUserNotificationCenter.current()
////        
////        // Remove any existing notifications
////        notificationCenter.removeAllPendingNotificationRequests()
////        
////        if timeRemaining > 0 {
////            // Create notification content
////            let content = UNMutableNotificationContent()
////            content.title = "Rest Timer"
////            content.body = "\(timeRemaining)s remaining"
////            content.sound = nil  // No sound for updates
////            
////            // Create trigger for immediate delivery
////            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
////            
////            // Create request
////            let request = UNNotificationRequest(identifier: "timer", content: content, trigger: trigger)
////            
////            // Schedule notification
////            notificationCenter.add(request)
////        }
////    }
////    
////    func startTimer(time : Int) {
////        stopTimer()
////        timeRemaining = time
////        
////        let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
////        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
////        
////        timer.setEventHandler { [weak self] in
////            guard let self = self else { return }
////            
////            DispatchQueue.main.async {
////                if self.timeRemaining > 0 {
////                    self.timeRemaining -= 1
////                }
////                
////                if self.timeRemaining <= 0 {
////                    self.stopTimer()
////                    // Send final notification when timer completes
////                    self.sendTimerCompletedNotification()
////                }
////            }
////        }
////        
////        dispatchTimer = timer
////        timer.resume()
////        
////        let backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
////            self?.stopTimer()
////        }
////        
////        if backgroundTask == .invalid {
////            stopTimer()
////        }
////    }
////    
////    private func sendTimerCompletedNotification() {
////        let content = UNMutableNotificationContent()
////        content.title = "Rest Timer Complete"
////        content.body = activeExercise != nil ? "Time to start \(activeExercise!.template.name)" : "Time to start next exercise"
////        content.sound = .default
////        
////        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
////        let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
////        
////        UNUserNotificationCenter.current().add(request)
////    }
////    
////    func stopTimer() {
////        dispatchTimer?.cancel()
////        dispatchTimer = nil
////        timeRemaining = 0
////        
////        // Remove any pending notifications when stopping the timer
////        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
////    }
//    var currentRoutine: Routine?
//    var completedSets = Set<String>()
//    var timeRemaining: Int = 0 {
//        didSet {
//            updateNotification()
//        }
//    }
//    var activeExercise: Exercise?
//    var activeSetIndex: Int?
//    var isWorkoutInProgress: Bool = false
//    
//    private var dispatchTimer: DispatchSourceTimer?
//    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
//    private var timerStartTime: Date?
//    private var originalDuration: Int = 0
//    
//    init() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("Notification permission granted")
//            }
//        }
//    }
//    
//    func startTimer(time : Int) {
//        stopTimer()
//        originalDuration = time
//        timeRemaining = time
//        timerStartTime = Date()
//        
//        // Schedule a local notification for when the timer should complete
//        scheduleTimerCompletionNotification(timeRemaining: time)
//        
//        let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
//        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
//        
//        timer.setEventHandler { [weak self] in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                if self.timeRemaining > 0 {
//                    self.timeRemaining -= 1
//                }
//                
//                if self.timeRemaining <= 0 {
//                    self.stopTimer()
//                }
//            }
//        }
//        
//        dispatchTimer = timer
//        timer.resume()
//        
//        // Start background task
//        registerBackgroundTask()
//    }
//    
//    private func registerBackgroundTask() {
//        // End any existing background task
//        endBackgroundTask()
//        
//        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
//            print("Background task expiring...")
//            self?.scheduleTimerCompletionNotification(timeRemaining: self?.timeRemaining ?? 0)
//            self?.endBackgroundTask()
//        }
//        
//        assert(backgroundTaskIdentifier != .invalid)
//    }
//    
//    private func endBackgroundTask() {
//        if backgroundTaskIdentifier != .invalid {
//            print("Ending background task...")
//            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//            backgroundTaskIdentifier = .invalid
//        }
//    }
//    
//    private func scheduleTimerCompletionNotification(timeRemaining: Int) {
//        // Remove any existing notifications
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        
//        if timeRemaining > 0 {
//            let content = UNMutableNotificationContent()
//            content.title = "Rest Timer Complete"
//            content.body = activeExercise != nil ? "Time to start \(activeExercise!.template.name)" : "Time to start next exercise"
//            content.sound = .default
//            // Schedule the notification for when the timer should complete
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false)
//            let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
//            
//            UNUserNotificationCenter.current().add(request)
//        }
//    }
//    
//    private func updateNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "Rest Timer"
//        content.body = "\(timeRemaining)s remaining" + (activeExercise != nil ? " until \(activeExercise!.template.name)" : "")
//        content.sound = nil
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
//        let request = UNNotificationRequest(identifier: "timerUpdate", content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request)
//    }
//    
//    func stopTimer() {
//        dispatchTimer?.cancel()
//        dispatchTimer = nil
//        timeRemaining = 0
//        timerStartTime = nil
//        endBackgroundTask()
//        
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//    }

@Observable class WorkoutManager {
    var currentRoutine: Routine?
    var completedSets = Set<String>()
    var timeRemaining: Int = 0 {
        didSet {
            updateNotification()
        }
    }
    var activeExercise: Exercise?
    var activeSetIndex: Int?
    var isWorkoutInProgress: Bool = false
    
    private var dispatchTimer: DispatchSourceTimer?
    private var timerStartTime: Date?
    private var originalDuration: Int = 0
    private let backgroundTaskIdentifier = "com.yourdomain.newtonnotes.timerprocessing"
    
    init() {
        registerBackgroundTasks()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGProcessingTask)
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Schedule the next background task
        scheduleBackgroundTask()
        
        // Check if we need to update the timer
        if let startTime = timerStartTime {
            let elapsed = Int(Date().timeIntervalSince(startTime))
            timeRemaining = max(0, originalDuration - elapsed)
            
            if timeRemaining <= 0 {
                stopTimer()
                sendTimerCompletedNotification()
            }
        }
        
        task.setTaskCompleted(success: true)
    }
    
    func startTimer(time : Int) {
        stopTimer()
        originalDuration = time
        timeRemaining = time
        timerStartTime = Date()
        
        scheduleBackgroundTask()
        scheduleTimerCompletionNotification(timeRemaining: time)
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                }
                
                if self.timeRemaining <= 0 {
                    self.stopTimer()
                    self.sendTimerCompletedNotification()
                }
            }
        }
        
        dispatchTimer = timer
        timer.resume()
    }
    
    private func scheduleTimerCompletionNotification(timeRemaining: Int) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if timeRemaining > 0 {
            let content = UNMutableNotificationContent()
            content.title = "Rest Timer Complete"
            content.body = activeExercise != nil ? "Time to start \(activeExercise!.template.name)" : "Time to start next exercise"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false)
            let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func sendTimerCompletedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer Complete"
        content.body = activeExercise != nil ? "Time to start \(activeExercise!.template.name)" : "Time to start next exercise"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func updateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer"
        content.body = "\(timeRemaining)s remaining" + (activeExercise != nil ? " until \(activeExercise!.template.name)" : "")
        content.sound = nil
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "timerUpdate", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func stopTimer() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        timeRemaining = 0
        timerStartTime = nil
        originalDuration = 0
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func startWorkout(routine: Routine) {
        currentRoutine = routine
        isWorkoutInProgress = true
        completedSets.removeAll()
        stopTimer()
    }
    
    func endWorkout() {
        currentRoutine = nil
        isWorkoutInProgress = false
        completedSets.removeAll()
        stopTimer()
    }
    
    func handleSetCompletion(_ exercise: Exercise, _ setIndex: Int, _ completed: Bool) {
        let identifier = "\(exercise.id)-\(setIndex)"
        
        if completed {
            completedSets.insert(identifier)
            if !isLastSet(exercise, setIndex) {
                startTimer(time: exercise.restTime)
                activeExercise = exercise
                activeSetIndex = setIndex
            }
        } else {
            completedSets.remove(identifier)
            if activeExercise?.id == exercise.id && activeSetIndex == setIndex {
                stopTimer()
            }
        }
    }
    
    private func isLastSet(_ exercise: Exercise, _ setIndex: Int) -> Bool {
        guard let routine = currentRoutine,
              let lastExercise = routine.exercises.last else {
            return false
        }
        return lastExercise.id == exercise.id && setIndex == exercise.sets.count - 1
    }
}
