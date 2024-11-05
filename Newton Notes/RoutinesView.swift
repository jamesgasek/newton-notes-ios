//
//  ExercisesView.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/2/24.
//

import Foundation
import SwiftUI
import SwiftData


// Main Routines View
struct RoutinesView: View {
    @Query private var routines: [Routine]
    @State private var showingAddRoutine = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(routines) { routine in
                    NavigationLink {
                        RoutineDetailView(routine: routine)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(routine.name)
                                .font(.headline)
                            Text("\(routine.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
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
}

// Routine Detail View
struct RoutineDetailView: View {
    let routine: Routine
    
    var body: some View {
        List {
            Section("Exercises") {
                ForEach(routine.exercises, id: \.name) { exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(exercise.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let notes = exercise.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(routine.name)
    }
}

// AddExerciseView - This adds exercises to your global exercise library
struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var exerciseName = ""
    @State private var category = "Other"
    @State private var notes = ""
    
    let categories = [
        "Chest", "Back", "Legs", "Shoulders",
        "Arms", "Core", "Cardio", "Other"
    ]
    
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
                        let exercise = Exercise(
                            name: exerciseName,
                            category: category,
                            notes: notes.isEmpty ? nil : notes
                        )
                        modelContext.insert(exercise)  // Add to SwiftData
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(exerciseName.isEmpty)
                }
            }
        }
    }
}

// AddRoutineView - This creates new routines using exercises from your library
struct AddRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var routineName = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showingAddExercise = false
    @Query private var availableExercises: [Exercise]  // This gets all exercises from SwiftData
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Routine Name", text: $routineName)
                }
                
                Section("Selected Exercises") {
                    ForEach(selectedExercises, id: \.name) { exercise in
                        Text(exercise.name)
                    }
                    .onDelete(perform: removeExercises)
                    .onMove(perform: moveExercise)
                    
                    Button(action: { showingAddExercise = true }) {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
                
                Section("Exercise Library") {
                    ForEach(availableExercises, id: \.name) { exercise in
                        if !selectedExercises.contains(where: { $0.name == exercise.name }) {
                            Button(action: {
                                selectedExercises.append(exercise)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    Text(exercise.category)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let routine = Routine(name: routineName, exercises: selectedExercises)
                        modelContext.insert(routine)  // Add to SwiftData
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(routineName.isEmpty || selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }
    
    private func removeExercises(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }
}



//public struct Exersizekj

#Preview {
    ContentView()
        .modelContainer(for: [Routine.self, Exercise.self, ExerciseSet.self], inMemory: true)
}



