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
                            RoutineDetailView(routine: routine)
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
    
//    private func startRoutine(_ routine: Routine) {
//        // You'll implement this to navigate to your workout view
//        print("Starting routine: \(routine.name)")
//        WorkoutView()
//    }
}

struct RoutineDetailView: View {
    let routine: Routine
    
    var body: some View {
        List {
            Section("Exercises") {
                ForEach(routine.exercises, id: \.template.name) { exercise in
                    NavigationLink {
                        ExerciseDetailView(exercise: exercise)
                    } label : {
                    VStack(alignment: .leading) {
                        Text(exercise.template.name)
                            .font(.headline)
                        Text(exercise.template.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                }
            }
        }
        .navigationTitle(routine.name)
    }
}

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

struct AddRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var routineName = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showingAddExercise = false
    @Query(sort: \ExerciseTemplate.name) private var availableTemplates: [ExerciseTemplate]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Routine Name", text: $routineName)
                }
                
                Section("Selected Exercises") {
                    ForEach(selectedExercises.indices, id: \.self) { exerciseIndex in
                        ExerciseRowView(exercise: $selectedExercises[exerciseIndex])
                    }
                    .onDelete(perform: removeExercises)
                    .onMove(perform: moveExercise)
                    
                    Button(action: { showingAddExercise = true }) {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
                
                Section("Exercise Library") {
                    ForEach(availableTemplates) { template in
                        if !selectedExercises.contains(where: { $0.template.id == template.id }) {
                            Button(action: {
                                addExerciseFromTemplate(template)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(template.name)
                                        .font(.headline)
                                    Text(template.category)
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
                        saveRoutine()
                    }
                    .disabled(routineName.isEmpty || selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseTemplateView()
            }
        }
    }
    
    private func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let defaultSets = [
            ExerciseSet(weight: 0, reps: 0),
            ExerciseSet(weight: 0, reps: 0),
            ExerciseSet(weight: 0, reps: 0)
        ]
        let newExercise = Exercise(template: template, sets: defaultSets)
        selectedExercises.append(newExercise)
    }
    
    private func saveRoutine() {
        let routine = Routine(name: routineName, exercises: selectedExercises)
        modelContext.insert(routine)
        try? modelContext.save()
        dismiss()
    }
    
    private func removeExercises(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }
}

// Separate view for exercise row to simplify bindings
struct ExerciseRowView: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        DisclosureGroup {
            ForEach(exercise.sets.indices, id: \.self) { setIndex in
                SetRowView(set: $exercise.sets[setIndex], setNumber: setIndex + 1)
            }
            
            // Add/Remove set buttons
            HStack {
                Button(action: addSet) {
                    Label("Add Set", systemImage: "plus.circle.fill")
                }
                
                if !exercise.sets.isEmpty {
                    Spacer()
                    Button(action: removeSet) {
                        Label("Remove Set", systemImage: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.top, 5)
        } label: {
            VStack(alignment: .leading) {
                Text(exercise.template.name)
                    .font(.headline)
                Text(exercise.template.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func addSet() {
        exercise.sets.append(ExerciseSet())
    }
    
    private func removeSet() {
        if !exercise.sets.isEmpty {
            exercise.sets.removeLast()
        }
    }
}

// Separate view for set row to further simplify bindings
struct SetRowView: View {
    @Binding var set: ExerciseSet
    let setNumber: Int
    
    var body: some View {
        HStack {
            Text("Set \(setNumber)")
            Spacer()
            
            TextField("Weight", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 60)
            Text("lbs")
            
            TextField("Reps", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .frame(width: 40)
            Text("reps")
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        List {
            Section("Sets") {
                ForEach(exercise.sets) { set in
                    VStack(alignment: .leading) {
                        Text("\(set.weight) lbs")  // or kg, depending on your units
                            .font(.headline)
                        Text("\(set.reps) reps")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(exercise.template.name)
    }
}
