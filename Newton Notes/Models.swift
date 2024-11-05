//
//  Models.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/2/24.
//

import Foundation
import SwiftUI
import SwiftData

// Model definitions
@Model
class Routine {
    var name: String
    var exercises: [Exercise]
    var createdAt: Date
    
    init(name: String, exercises: [Exercise] = [], createdAt: Date = Date()) {
        self.name = name
        self.exercises = exercises
        self.createdAt = createdAt
    }
}


@Model
public class Exercise {
    var name: String
    var category: String
    var notes: String?
    
    init(name: String, category: String, notes: String? = nil) {
        self.name = name
        self.category = category
        self.notes = notes
    }
}

@Model
public class ExerciseSet {
    var exercise: Exercise
    var weight: Double
    var reps: Int
    var timestamp: Date
    
    init(exercise: Exercise, weight: Double, reps: Int, timestamp: Date = Date()) {
        self.exercise = exercise
        self.weight = weight
        self.reps = reps
        self.timestamp = timestamp
    }
}
