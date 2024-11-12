//
//  ExercisesView.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/2/24.
//

import Foundation
import SwiftUI
import SwiftData


struct RoutinesView: View {
    @Query private var routines: [Routine]
    @State private var showingAddRoutine = false
    @Environment(\.modelContext) private var modelContext

    
    var body: some View {
        NavigationStack {
            List {
                ForEach(routines) { routine in
                    NavigationLink {
                        WorkoutView(routine: routine)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(routine.name)
                                .font(.headline)
                            Text("\(routine.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        NavigationLink{
                            EditRoutineView(routine: routine)
                                            } label: {
                                                Text("Edit")
                                            }
                                        }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                deleteRoutine(routine)
                                            } label: {
                                                Text("Delete")
                                            }.tint(.red)
                                        }
                }
            }
            .navigationTitle("Routines")
            .toolbar {
                Button(action: { showingAddRoutine = true }) {
                    Label("Add Routine", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddRoutine) {
                AddRoutineView()
            }
        }

    }
    private func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
        try? modelContext.save()
    }
}
//
//struct EditRoutineView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Bindable var routine: Routine
//    
//    var body: some View {
//        List {
//            Section("Exercises") {
//                ForEach(routine.exercises, id: \.template.name) { exercise in
//                    NavigationLink {
//                        ExerciseDetailView(exercise: exercise)
//                    } label: {
//                        VStack(alignment: .leading) {
//                            Text(exercise.template.name)
//                                .font(.headline)
//                            Text(exercise.template.category)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                .onMove { from, to in
//                    print("Before move:", routine.exercises.map { $0.template.name })
//                    
//                    // Create a new array, make the change, and assign it back
//                    var newArray = Array(routine.exercises)
//                    newArray.move(fromOffsets: from, toOffset: to)
//                    routine.exercises = newArray
//                    
//                    print("After move:", routine.exercises.map { $0.template.name })
//                    
//                    do {
//                        try modelContext.save()
//                        print("Save completed")
//                    } catch {
//                        print("Save failed:", error)
//                    }
//                }
//            }
//        }
//        .navigationTitle(routine.name)
//        .toolbar {
//            EditButton()
//        }
//    }
//}

struct AddExerciseTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var exerciseName = ""
    @State private var category = "Other"
    @State private var notes = ""
    
    let categories = [
        "Chest", "Back", "Legs", "Shoulders",
        "Arms", "Core", "Cardio", "Other"
    ]
   
    private func saveExercise() {
        
        let template = ExerciseTemplate(
            name: exerciseName,
            category: category
        )
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            print("Successfully saved exercise: \(template.name)")
        } catch {
            print("Failed to save exercise: \(error)")
        }
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise Name", text: $exerciseName)
                
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                
                TextField("Notes (Optional)", text: $notes)
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(exerciseName.isEmpty)
                }
            }
        }
    }
}

