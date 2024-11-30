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
    var restTime: Int
    
    init(template: ExerciseTemplate, sets: [ExerciseSet] = [], restTime: Int = 90) {
        self.template = template
        self.sets = sets
        self.restTime = restTime
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

@Model
class AnalyticsLog: Identifiable {
    @Attribute(.unique) let id: UUID
    var name: String
    var value: Double
    var timestamp: Date
    var isCumulative: Bool?
    var unit: String?
    var dailyGoal: Double?
    
    var isActuallyCumulative: Bool {
        isCumulative ?? false
    }
    
    var actualUnit: String {
        unit ?? ""
    }
    
    var actualDailyGoal: Double {
        dailyGoal ?? 0
    }
    
    init(name: String, value: Double, timestamp: Date = Date(), isCumulative: Bool = false, unit: String = "", dailyGoal: Double? = nil) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.timestamp = timestamp
        self.isCumulative = isCumulative
        self.unit = unit
        self.dailyGoal = dailyGoal
    }
}

//for import / export logic

struct ExportData: Codable {
    var routines: [RoutineData]
    var exerciseTemplates: [ExerciseTemplateData]
    var analyticsLogs: [AnalyticsLogData]
}

struct RoutineData: Codable {
    var name: String
    var exercises: [ExerciseData]
    var createdAt: Date
}

struct ExerciseTemplateData: Codable {
    var name: String
    var category: String
}

struct ExerciseData: Codable {
    var template: ExerciseTemplateData
    var sets: [ExerciseSetData]
    var restTime: Int
}

struct ExerciseSetData: Codable {
    var weight: Double
    var reps: Int
    var timestamp: Date
}

struct AnalyticsLogData: Codable {
    var name: String
    var value: Double
    var unit: String
    var timestamp: Date
}
