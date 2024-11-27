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
import Observation
import ActivityKit

@Observable class WorkoutManager: NSObject {
    var currentRoutine: Routine?
    var completedSets = Set<String>()
    var timeRemaining: Int = 0 {
        didSet {
            if timeRemaining > 0 {
                updateLiveActivity()
            } else {
                endLiveActivity()
            }
        }
    }
    var activeExercise: Exercise?
    var activeSetIndex: Int?
    var isWorkoutInProgress: Bool = false
    
    private var dispatchTimer: DispatchSourceTimer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var endTime: Date?
    private var currentActivity: Activity<TimerWidgetAttributes>?
    
    override init() {
        super.init()
        
        // Handle app going to background
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleAppBackground),
                                             name: UIApplication.willResignActiveNotification,
                                             object: nil)
    }
    
    @objc private func handleAppBackground() {
        // No need to handle background specially - Live Activity continues in background
    }
    
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = TimerWidgetAttributes(initialSeconds: timeRemaining)
        let contentState = TimerWidgetAttributes.ContentState(
            endTime: Date().addingTimeInterval(TimeInterval(timeRemaining)),
            secondsRemaining: timeRemaining
        )
        
        Task {
            do {
                print("Starting live activity")
                let activity = try Activity.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: nil
                )
                
                currentActivity = activity
                print("Live activity started")
            } catch {
                print("Error starting live activity: \(error)")
            }
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            let updatedContentState = TimerWidgetAttributes.ContentState(
                endTime: Date().addingTimeInterval(TimeInterval(timeRemaining)),
                secondsRemaining: timeRemaining
            )
            
            await activity.update(using: updatedContentState)
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(using: TimerWidgetAttributes.ContentState(
                endTime: Date(),
                secondsRemaining: 0
            ), dismissalPolicy: .immediate)
            
            currentActivity = nil
        }
    }
    
    func startTimer(time: Int) {
        stopTimer()
        timeRemaining = time
        endTime = Date().addingTimeInterval(TimeInterval(time))
        
        // Start Live Activity
        startLiveActivity()
        
        // Start background task
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopTimer()
        }
        
        // Create and configure timer
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            
            // Handle timer completion
            if self.timeRemaining == 0 {
                self.stopTimer()
            }
        }
        
        timer.resume()
        dispatchTimer = timer
    }
    
    func stopTimer() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        endLiveActivity()
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

extension WorkoutManager {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // No need to handle notifications - Live Activity is used instead
        completionHandler([])
    }
}
