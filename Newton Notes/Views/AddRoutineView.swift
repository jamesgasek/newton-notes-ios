import SwiftUI
import SwiftData
import os.log

struct AddRoutineView: View {
    private let logger = Logger(subsystem: "com.jamesgasek.newtonnotes", category: "AddRoutineView")
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var routineName = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showingAddExercise = false
    @Query(sort: \ExerciseTemplate.name) private var availableTemplates: [ExerciseTemplate]
    
    var body: some View {
        // Body remains the same...
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
                AddExerciseTemplateView { template in
                    addExerciseFromTemplate(template)
                }
            }
        }
    }

    private func addExerciseFromTemplate(_ template: ExerciseTemplate) {
    logger.debug("Starting addExerciseFromTemplate for template: \(template.name)")
    
    // Set the sortOrder for the new exercise based on existing exercises
    let exerciseSortOrder = selectedExercises.map(\.sortOrder).max() ?? -1
    
    // Create the exercise first and insert it into the context
    let newExercise = Exercise(template: template, sets: [], restTime: 90, sortOrder: exerciseSortOrder + 1)
    modelContext.insert(newExercise)
    logger.debug("Created exercise shell with sortOrder: \(newExercise.sortOrder)")
    
    // Create and add sets one by one, ensuring they're in the same context
    for i in 0..<3 {
        let set = ExerciseSet(weight: 0, reps: 10, sortOrder: i)
        modelContext.insert(set)
        newExercise.sets.append(set)
        logger.debug("Added set \(i) to exercise")
    }
    
    // Add to selected exercises array
    selectedExercises.append(newExercise)
    logger.debug("Added exercise to selectedExercises array")
    
    // Save the context
    do {
        try modelContext.save()
        logger.debug("Successfully saved context")
    } catch {
        logger.error("Error in addExerciseFromTemplate: \(error.localizedDescription)")
    }
}
    
    private func saveRoutine() {
        logger.debug("Starting saveRoutine with name: \(routineName) and \(selectedExercises.count) exercises")
        
        do {
            // Create the routine first
            let routine = Routine(name: routineName, exercises: [])
            modelContext.insert(routine)
            
            // Add each exercise to the routine
            for exercise in selectedExercises {
                // Create a new exercise with the same template
                let newExercise = Exercise(template: exercise.template, sets: [], restTime: exercise.restTime)
                modelContext.insert(newExercise)
                
                // Create and add new sets
                for set in exercise.sets {
                    let newSet = ExerciseSet(weight: set.weight, reps: set.reps, sortOrder: set.sortOrder)
                    modelContext.insert(newSet)
                    newExercise.sets.append(newSet)  // Using append since sets is an array
                }
                
                // Add the exercise to the routine
                routine.exercises.append(newExercise)  // Using append since exercises is an array
            }
            
            logger.debug("Created and inserted routine with \(routine.exercises.count) exercises")
            
            try modelContext.save()
            logger.debug("Successfully saved routine")
            dismiss()
        } catch {
            logger.error("Error saving routine: \(error.localizedDescription)")
        }
    }
    
    private func removeExercises(at offsets: IndexSet) {
        logger.debug("Removing exercises at offsets: \(offsets)")
        selectedExercises.remove(atOffsets: offsets)
    }
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
        logger.debug("Moving exercise from \(source) to \(destination)")
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }
}
