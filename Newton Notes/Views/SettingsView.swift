import Foundation
import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var preferenceManager: PreferenceManager
    
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [Routine]
    @Query private var exerciseTemplates: [ExerciseTemplate]
    @Query private var analyticsLogs: [AnalyticsLog]
    
    @State private var documentPickerCoordinator: DocumentPickerCoordinator?
    @State private var showingImportAlert = false
    @State private var importAlertMessage = ""
    @State private var showingDeleteConfirmation = false

    
    private func importData() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPickerCoordinator = DocumentPickerCoordinator(parent: self)
        documentPicker.delegate = documentPickerCoordinator
        documentPicker.allowsMultipleSelection = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(documentPicker, animated: true)
        }
    }
    
    private func exportData() {
        let exportData = ExportData(
            routines: routines.map { routine in
                RoutineData(
                    name: routine.name,
                    exercises: routine.exercises.map { exercise in
                        ExerciseData(
                            template: ExerciseTemplateData(
                                name: exercise.template.name,
                                category: exercise.template.category
                            ),
                            sets: exercise.sets.map { set in
                                ExerciseSetData(
                                    sortOrder: set.sortOrder,
                                    weight: set.weight,
                                    reps: set.reps
                                )
                            },
                            restTime: exercise.restTime,
                            sortOrder: exercise.sortOrder
                        )
                    },
                    createdAt: routine.createdAt
                )
            },
            exerciseTemplates: exerciseTemplates.map { template in
                ExerciseTemplateData(
                    name: template.name,
                    category: template.category
                )
            },
            analyticsLogs: analyticsLogs.map { log in
                AnalyticsLogData(
                    name: log.name,
                    value: log.value,
                    unit: log.actualUnit,
                    timestamp: log.timestamp
                )
            }
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(exportData)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "fitness_data_\(Date().ISO8601Format()).json"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            
            // Share the file
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            // Present the share sheet
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Export failed: \(error)")
        }
    }
    
    class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
        let parent: SettingsView
        
        init(parent: SettingsView) {
            self.parent = parent
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedFileURL = urls.first else {
                print("No file selected")
                return
            }
            
            do {
                print("Starting import from: \(selectedFileURL)")
                let data = try Data(contentsOf: selectedFileURL)
                print("File data loaded, size: \(data.count) bytes")
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let importedData = try decoder.decode(ExportData.self, from: data)
                print("Data decoded successfully")
                print("Found \(importedData.exerciseTemplates.count) templates")
                print("Found \(importedData.routines.count) routines")
                print("Found \(importedData.analyticsLogs.count) logs")
                
                // Keep track of templates we create
                var createdTemplates: [String: ExerciseTemplate] = [:]
                
                // Import exercise templates first
                for templateData in importedData.exerciseTemplates {
                    if !parent.exerciseTemplates.contains(where: { $0.name == templateData.name }) {
                        print("Importing template: \(templateData.name)")
                        let template = ExerciseTemplate(
                            name: templateData.name,
                            category: templateData.category
                        )
                        parent.modelContext.insert(template)
                        createdTemplates[template.name] = template
                    }
                }
                
                // Import routines and exercises
                for routineData in importedData.routines {
                    if !parent.routines.contains(where: { $0.name == routineData.name }) {
                        print("Importing routine: \(routineData.name)")
                        
                        let exercises = try routineData.exercises.map { exerciseData -> Exercise in
                            // First check our newly created templates, then existing ones, or create if needed
                            let template = createdTemplates[exerciseData.template.name] ??
                                         parent.exerciseTemplates.first(where: { $0.name == exerciseData.template.name }) ??
                                         {
                                            let newTemplate = ExerciseTemplate(
                                                name: exerciseData.template.name,
                                                category: exerciseData.template.category
                                            )
                                            parent.modelContext.insert(newTemplate)
                                            createdTemplates[newTemplate.name] = newTemplate
                                            return newTemplate
                                         }()
                            
                            print("Creating exercise with template: \(template.name)")
                            let sets = exerciseData.sets.map { setData in
                                ExerciseSet(
                                    weight: setData.weight,
                                    reps: setData.reps,
                                    sortOrder: setData.sortOrder
                                )
                            }
                            
                            return Exercise(
                                template: template,
                                sets: sets,
                                restTime: exerciseData.restTime,
                                sortOrder: exerciseData.sortOrder
                            )
                        }
                        
                        let routine = Routine(
                            name: routineData.name,
                            exercises: exercises,
                            createdAt: routineData.createdAt
                        )
                        parent.modelContext.insert(routine)
                    } else {
                        print("Skipping existing routine: \(routineData.name)")
                    }
                }
                
                // Import analytics logs
                for logData in importedData.analyticsLogs {
                    if !parent.analyticsLogs.contains(where: {
                        $0.name == logData.name &&
                        $0.timestamp == logData.timestamp
                    }) {
                        print("Importing log: \(logData.name)")
                        let log = AnalyticsLog(
                            name: logData.name,
                            value: logData.value,
                            timestamp: logData.timestamp,
                            unit: logData.unit
                        )
                        parent.modelContext.insert(log)
                    } else {
                        print("Skipping existing log: \(logData.name)")
                    }
                }
                
                try parent.modelContext.save()
                print("Import completed successfully")
                parent.importAlertMessage = "Import completed successfully!"
                parent.showingImportAlert = true
                
            } catch {
                print("Import failed with error: \(error)")
                parent.importAlertMessage = "Import failed: \(error.localizedDescription)"
                parent.showingImportAlert = true
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key) - \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type) - \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Missing value: expected \(type) - \(context.debugDescription)")
                    default:
                        print("Other decoding error: \(decodingError)")
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Units") {
                    
                    Picker("Weight Unit", selection: $preferenceManager.weightUnit) {
                        Text("Kilograms (kg)").tag("kg")
                        Text("Pounds (lbs)").tag("lbs")
                    }
                    Picker("Distance Unit", selection: $preferenceManager.distanceUnit) {
                        Text("Kilometers (km)").tag("km")
                        Text("Miles (mi)").tag("mi")
                    }
                }
                
                Section("Export / Import") {
                    Button(action: {
                        exportData()
                    }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        importData()
                    }) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                    // In the Export / Import section, after the import button:
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }

                }
                
                Link("Rate App", destination: URL(string: "https://apps.apple.com")!)
                Link("Privacy Policy", destination: URL(string: "http://www.gasek.net/newtonnotes/privacypolicy")!)
                Button(action: {
                    if let url = URL(string: "mailto:james@gasek.net?subject=Newton%20Notes%20Feedback") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Feedback / Suggestions", systemImage: "envelope")
                }
            }
            .navigationTitle("Settings")
            .alert("Import Status", isPresented: $showingImportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importAlertMessage)
            }
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Data", role: .destructive) {
                    // Delete all analytics logs
                    for log in analyticsLogs {
                        modelContext.delete(log)
                    }
                    
                    // Delete all routines (this will cascade delete exercises and sets)
                    for routine in routines {
                        modelContext.delete(routine)
                    }
                    
                    // Delete all exercise templates
                    for template in exerciseTemplates {
                        modelContext.delete(template)
                    }
                    
                    try? modelContext.save()
                }
            } message: {
                Text("Warning: this action is irreversible! We recommend exporting your existing data as a backup before deletion.")
            }
        }
    }
}
