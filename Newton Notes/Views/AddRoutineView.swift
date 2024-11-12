//
//  AddRoutineView.swift
//  Newton Notes
//
//  Created by James Gasek on 11/6/24.
//

import SwiftUI
import SwiftData

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
                    ForEach(selectedExercises.indices, id: \.self) { index in
                        NavigationLink {
                            ExerciseDetailView(exercise: selectedExercises[index])
                        } label: {
                            VStack(alignment: .leading) {
                                Text(selectedExercises[index].template.name)
                                    .font(.headline)
                                Text(selectedExercises[index].template.category)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
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
//                AddExerciseTemplateView()
                AddExerciseTemplateView { template in
                    addExerciseFromTemplate(template)
                }
            }
        }
    }
    
    private func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let defaultSets = [
            ExerciseSet(weight: 0, reps: 10),
            ExerciseSet(weight: 0, reps: 10),
            ExerciseSet(weight: 0, reps: 10)
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
