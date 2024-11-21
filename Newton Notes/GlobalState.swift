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
import os.log

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
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var endTime: Date?

    
    init() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
        
//        UNUserNotificationCenter.current().delegate = self
    }
    
    
    
    func startTimer(time : Int) {
        stopTimer()
        timeRemaining = time
        endTime = Date().addingTimeInterval(TimeInterval(time))
        
        // Schedule end notification
        scheduleTimerCompletionNotification(timeRemaining: time)
        
        // Start background task
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopTimer()
        }
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                if self.timeRemaining == 0 {
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
        
        // Schedule completion notification
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer Complete"
        content.body = activeExercise != nil ? "Time to start \(activeExercise!.template.name)" : "Time to start next exercise"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false)
        let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func updateNotification() {
        // Update current notification
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer"
        content.body = "\(timeRemaining)s remaining" + (activeExercise != nil ? " until \(activeExercise!.template.name)" : "")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "timerUpdate", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
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
    
    func stopTimer() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        timeRemaining = 0
        endTime = nil
        
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
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

//extension WorkoutManager: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
//    ) {
//        // Only show in notification center, no banners
//        completionHandler([.list, .sound])
//    }
//}
