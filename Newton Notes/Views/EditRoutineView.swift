import SwiftUI
import SwiftData


struct EditRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var routine: Routine
    @Query(sort: \ExerciseTemplate.name) private var availableTemplates: [ExerciseTemplate]
    @State private var showingAddExercise = false
    @State private var editingName = false
    @State private var routineName: String
    
    @State private var showingNameAlert = false



    init(routine: Routine) {
        self.routine = routine
        _routineName = State(initialValue: routine.name)
    }
    
    var body: some View {
        List {
//            Section {
//                if editingName {
//                    TextField("Routine Name", text: $routineName, onCommit: {
//                        routine.name = routineName
//                        try? modelContext.save()
//                        editingName = false
//                    })
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                } else {
//                    HStack {
//                        Text(routine.name)
//                            .font(.headline)
//                        Spacer()
//                        Button(action: { editingName = true }) {
//                            Image(systemName: "pencil")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                }
//            }
//            Section {
//                TextField("Routine Name", text: $routineName, onCommit: {
//                    routine.name = routineName
//                    try? modelContext.save()
//                })
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            } header: {
//                Text("") // Empty header for consistent spacing
//            }
            
            Section {
                let sortedExercises = routine.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })
                ForEach(Array(sortedExercises.enumerated()), id: \.element.id) { index, exercise in
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
                    // Get sorted exercises
                    var exercises = routine.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })
                    
                    // Remove the exercises
                    exercises.remove(atOffsets: indexSet)
                    
                    // Update remaining sort orders
                    for (index, exercise) in exercises.enumerated() {
                        exercise.sortOrder = index
                    }
                    
                    // Update routine's exercises array
                    routine.exercises = exercises
                    
                    try? modelContext.save()
                }
                .onMove { source, destination in
                    // Get sorted exercises
                    var exercises = routine.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })
                    
                    // Move the exercise
                    exercises.move(fromOffsets: source, toOffset: destination)
                    
                    // Update all sort orders
                    for (index, exercise) in exercises.enumerated() {
                        exercise.sortOrder = index
                    }
                    
                    // Update routine's exercises array
                    routine.exercises = exercises
                    
                    try? modelContext.save()
                }
                
                Button(action: { showingAddExercise = true }) {
                    Label("Add Exercise", systemImage: "plus")
                }


            }
            header: {
                Text("Exercises")
            } footer: {
                Text("Swipe to delete. Drag to reorder")
            }
            
//            footer: {
//                Text("Swipe to delete. Drag to reorder")
//            }
            
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
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNameAlert = true }) {
                    Text("Rename")
                }
            }
        }
        .alert("Rename Routine", isPresented: $showingNameAlert) {
            TextField("Routine Name", text: $routineName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                routine.name = routineName
                try? modelContext.save()
            }
        } message: {
            Text("Enter a new name for this routine")
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseTemplateView { template in
                addExerciseFromTemplate(template)
            }
        }
    }
    
    private func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let defaultSets = [
            ExerciseSet(weight: 0, reps: 10, sortOrder: 0),
            ExerciseSet(weight: 0, reps: 10, sortOrder: 2),
            ExerciseSet(weight: 0, reps: 10, sortOrder: 3)
        ]
        
        let exercise = Exercise(
            template: template,
            sets: defaultSets,
            sortOrder: routine.exercises.count
        )
        
        routine.exercises.append(exercise)
        try? modelContext.save()
    }
}
