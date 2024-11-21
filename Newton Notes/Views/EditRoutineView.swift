import SwiftUI
import SwiftData

struct EditRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var routine: Routine
    @Query(sort: \ExerciseTemplate.name) private var availableTemplates: [ExerciseTemplate]
    @State private var showingAddExercise = false
    
    var body: some View {
        List {
            Section("Exercises") {
                ForEach(Array(routine.exercises.enumerated()), id: \.element.id) { index, exercise in
                    NavigationLink {
                        ExerciseDetailView(exercise: exercise)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(exercise.template.name)")
                                .font(.headline)
                            Text(exercise.template.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    routine.exercises.remove(atOffsets: indexSet)
                    try? modelContext.save()
                }
                .onMove { source, destination in
                    routine.exercises.move(fromOffsets: source, toOffset: destination)
                    try? modelContext.save()
                }
                
                Button(action: { showingAddExercise = true }) {
                    Label("Add Exercise", systemImage: "plus")
                }
            }
            
            Section("Exercise Library") {
                ForEach(availableTemplates) { template in
                    if !routine.exercises.contains(where: { $0.template.id == template.id }) {
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
        .navigationTitle(routine.name)
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseTemplateView { template in
                addExerciseFromTemplate(template)
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
        routine.exercises.append(newExercise)
        try? modelContext.save()
    }
}
