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
//                // Only update existing activity if we have one
//                if currentActivity != nil {
//                    updateLiveActivity()
//                }
            } else if oldValue > 0 {
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
    private var backgroundTaskQueue = DispatchQueue(label: "com.newton.backgroundTask", qos: .userInitiated)
    private var activityStartTime: Date?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleAppBackground),
                                             name: UIApplication.willResignActiveNotification,
                                             object: nil)
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleAppForeground),
                                             name: UIApplication.willEnterForegroundNotification,
                                             object: nil)
    }
    
    @objc private func handleAppBackground() {
        if timeRemaining > 0 {
            startBackgroundTask()
        }
    }
    
    @objc private func handleAppForeground() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    private func startBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
        }
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.backgroundTaskQueue.async {
                self?.startBackgroundTask()
            }
        }
    }
    
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled,
              timeRemaining > 0 else { return }
        
        // First, end any existing activities
        Task {
            for activity in Activity<TimerWidgetAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            
            // Then start our new activity
            activityStartTime = Date()
            let totalDuration = TimeInterval(timeRemaining)
            let endDate = activityStartTime!.addingTimeInterval(totalDuration)
            
            let attributes = TimerWidgetAttributes(name: activeExercise?.template.name ?? "Rest Timer")
            let contentState = TimerWidgetAttributes.ContentState(
                timerRange: activityStartTime!...endDate
            )
            
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
    
//    private func updateLiveActivity() {
//        guard let activity = currentActivity,
//              let startTime = activityStartTime,
//              timeRemaining > 0 else {
//            endLiveActivity()
//            return
//        }
//        
//        // Calculate how much time has elapsed since the start
//        let elapsedTime = Date().timeIntervalSince(startTime)
//        // Calculate the total duration based on elapsed time and remaining time
//        let totalDuration = elapsedTime + TimeInterval(timeRemaining)
//        // The end date should be start time plus total duration
//        let endDate = startTime.addingTimeInterval(totalDuration)
//        
//        Task {
//            let updatedContentState = TimerWidgetAttributes.ContentState(
//                timerRange: startTime...endDate
//            )
//            
//            do {
//                await activity.update(using: updatedContentState)
//            } catch {
//                print("Error updating live activity: \(error)")
//                currentActivity = nil
//            }
//        }
//    }
    
    private func endLiveActivity() {
        Task {
            // End all activities, not just the current one
            for activity in Activity<TimerWidgetAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            currentActivity = nil
            activityStartTime = nil
        }
    }
    
    func startTimer(time: Int) {
        stopTimer()
        timeRemaining = time
        endTime = Date().addingTimeInterval(TimeInterval(time))
        
        if UIApplication.shared.applicationState == .background {
            startBackgroundTask()
        }
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: backgroundTaskQueue)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                DispatchQueue.main.async {
                    self.timeRemaining -= 1
                }
            } else {
                DispatchQueue.main.async {
                    self.stopTimer()
                }
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
                // Start rest timer
                activeExercise = exercise
                activeSetIndex = setIndex
                startTimer(time: exercise.restTime)
                startLiveActivity() // Start live activity only for rest periods
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
    
    func skipCurrentPeriod() {
        if timeRemaining > 0 {
            if let _ = activeExercise, let _ = activeSetIndex {
                timeRemaining = 0
                activeExercise = nil
                activeSetIndex = nil
            }
            stopTimer()
        }
    }
}

extension WorkoutManager {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
}///
