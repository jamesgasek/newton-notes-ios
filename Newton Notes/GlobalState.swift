////
////  GlobalState.swift
////  Newton Notes
////
////  Created by James Gasek on 11/7/24.
////
//
//import Foundation
//
//@Observable class WorkoutManager {
//    var currentRoutine: Routine?
//    var completedSets = Set<String>()
//    var timeRemaining: Int = 0
//    var timer: Timer?
//    var activeExercise: Exercise?
//    var activeSetIndex: Int?
//    var isWorkoutInProgress: Bool = false
//    
//    func startTimer(time : Int) {
//        stopTimer()
//        timeRemaining = time
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if self.timeRemaining > 0 {
//                self.timeRemaining -= 1
//            } else {
//                self.stopTimer()
//            }
//        }
//    }
//    
//    func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//        timeRemaining = 0
//    }
//    
//    func startWorkout(routine: Routine) {
//        currentRoutine = routine
//        isWorkoutInProgress = true
//        completedSets.removeAll()
//        stopTimer()
//    }
//    
//    func endWorkout() {
//        currentRoutine = nil
//        isWorkoutInProgress = false
//        completedSets.removeAll()
//        stopTimer()
//    }
//    
//    func handleSetCompletion(_ exercise: Exercise, _ setIndex: Int, _ completed: Bool) {
//        let identifier = "\(exercise.id)-\(setIndex)"
//        
//        if completed {
//            completedSets.insert(identifier)
//            if !isLastSet(exercise, setIndex) {
//                startTimer(time: exercise.restTime)
//                activeExercise = exercise
//                activeSetIndex = setIndex
//            }
//        } else {
//            completedSets.remove(identifier)
//            if activeExercise?.id == exercise.id && activeSetIndex == setIndex {
//                stopTimer()
//            }
//        }
//    }
//    
//    private func isLastSet(_ exercise: Exercise, _ setIndex: Int) -> Bool {
//        guard let routine = currentRoutine,
//              let lastExercise = routine.exercises.last else {
//            return false
//        }
//        return lastExercise.id == exercise.id && setIndex == exercise.sets.count - 1
//    }
//}

import Foundation
import UIKit

@Observable class WorkoutManager {
    var currentRoutine: Routine?
    var completedSets = Set<String>()
    var timeRemaining: Int = 0
    var activeExercise: Exercise?
    var activeSetIndex: Int?
    var isWorkoutInProgress: Bool = false
    
    private var dispatchTimer: DispatchSourceTimer?
    
    func startTimer(time : Int) {
        stopTimer()
        timeRemaining = time
        
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
                }
            }
        }
        
        dispatchTimer = timer
        timer.resume()
        
        let backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopTimer()
        }
        
        if backgroundTask == .invalid {
            stopTimer()
        }
    }
    
    func stopTimer() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        timeRemaining = 0
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
