import Foundation
import SwiftUI
import SwiftData

@Model
class Routine {
    var name: String
    var exercises: [Exercise]  // Changed to RoutineExercise
    var createdAt: Date
    
    init(name: String, exercises: [Exercise] = [], createdAt: Date = Date()) {
        self.name = name
        self.exercises = exercises
        self.createdAt = createdAt
    }
}

@Model
public class ExerciseTemplate: Identifiable {
    public var id: String { name }  // Added Identifiable conformance
    var name: String
    var category: String
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
}

@Model
public class Exercise {
    var template: ExerciseTemplate
    var sets: [ExerciseSet]
    
    init(template: ExerciseTemplate, sets: [ExerciseSet] = []) {
        self.template = template
        self.sets = sets
    }
}

@Model
public class ExerciseSet {
    var weight: Double
    var reps: Int
    var timestamp: Date
    
    init(weight: Double = 0, reps: Int = 0, timestamp: Date = Date()) {
        self.weight = weight
        self.reps = reps
        self.timestamp = timestamp
    }
}
