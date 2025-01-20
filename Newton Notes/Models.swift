import Foundation
import SwiftUI
import SwiftData

enum SchemaVersions {
    static let v1 = Schema([
        Routine.self,
        Exercise.self,
        ExerciseTemplate.self,
        ExerciseSet.self,
        AnalyticsLog.self
    ])
    
    static let v2 = Schema([
        Routine.self,
        Exercise.self,
        ExerciseTemplate.self,
        ExerciseSet.self,
        AnalyticsLog.self
    ])
}

//extension SchemaMigrationPlan {
//    static var v1_to_v2: SchemaMigrationPlan {
//        SchemaMigrationPlan(
//            from: SchemaVersions.v1,
//            to: SchemaVersions.v2,
//            transformers: [
//                .custom(
//                    fromType: Routine.self,
//                    toType: Routine.self
//                ) { context, source, target in
//                    target.name = source.name
//                    target.exercises = source.exercises
//                    target.createdAt = source.createdAt
//                    target.sortOrder = 0  // Default value for existing routines
//                }
//            ]
//        )
//    }
//}

@Model
class Routine {
    var name: String
    var exercises: [Exercise]  // Changed to RoutineExercise
    var createdAt: Date
    var sortOrder: Int
    
    init(name: String, exercises: [Exercise] = [], createdAt: Date = Date(), sortOrder: Int = 0) {
        self.name = name
        self.exercises = exercises
        self.createdAt = createdAt
        self.sortOrder = sortOrder
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

//@Model
//public class Exercise {
//    var template: ExerciseTemplate
//    var sets: [ExerciseSet]
//    var restTime: Int
//    var sortOrder: Int
//    
//    init(template: ExerciseTemplate, sets: [ExerciseSet] = [], restTime: Int = 90, sortOrder: Int = 0) {
//        self.template = template
//        self.sets = sets
//        self.restTime = restTime
//        self.sortOrder = sortOrder
//    }
//}
//
//@Model
//public class ExerciseSet {
//    var weight: Double
//    var reps: Int
//    var timestamp: Date
//    
//    init(weight: Double = 0, reps: Int = 0, timestamp: Date = Date()) {
//        self.weight = weight
//        self.reps = reps
//        self.timestamp = timestamp
//    }
//}
// In ExerciseSet.swift - modify the model
@Model
public class ExerciseSet {
    var weight: Double
    var reps: Int
    var sortOrder: Int  // New field
    
    init(weight: Double = 0, reps: Int = 0, timestamp: Date = Date(), sortOrder: Int) {
        self.weight = weight
        self.reps = reps
        self.sortOrder = sortOrder
    }
}

// In Exercise.swift
@Model
public class Exercise {
    var template: ExerciseTemplate
    var sets: [ExerciseSet]
    var restTime: Int
    var sortOrder: Int
    
    var sortedSets: [ExerciseSet] {
        sets.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    init(template: ExerciseTemplate, sets: [ExerciseSet] = [], restTime: Int = 90, sortOrder: Int = 0) {
        self.template = template
        self.sets = sets
        self.restTime = restTime
        self.sortOrder = sortOrder
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
    var sortOrder: Int
}

struct ExerciseSetData: Codable {
    var sortOrder: Int
    var weight: Double
    var reps: Int
}

struct AnalyticsLogData: Codable {
    var name: String
    var value: Double
    var unit: String
    var timestamp: Date
}
