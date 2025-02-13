import SwiftUI

struct WorkoutView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @State private var manager: WorkoutManager
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Bool
    @EnvironmentObject private var preferenceManager: PreferenceManager
    
    init(routine: Routine, workoutManager: WorkoutManager) {
        self.routine = routine
        _manager = State(initialValue: workoutManager)
    }
    
    private func fieldIdentifier(exerciseId: String, setIndex: Int, isWeight: Bool) -> String {
        "\(exerciseId)-\(setIndex)-\(isWeight ? "weight" : "reps")"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(routine.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })) { exercise in
                        Section(header: Text(exercise.template.name).font(.headline)) {
                            ForEach(Array(exercise.sortedSets.enumerated()), id: \.offset) { index, set in
                                HStack {
                                    TextField("Weight", value: Binding(
                                        get: { set.weight },
                                        set: {
                                            set.weight = $0
                                            try? modelContext.save()
                                        }
                                    ), format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                    .keyboardType(.decimalPad)
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: true)
                                    
                                    Text(preferenceManager.weightUnit)
                                    
                                    TextField("Reps", value: Binding(
                                        get: { set.reps },
                                        set: {
                                            set.reps = $0
                                            try? modelContext.save()
                                        }
                                    ), format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                                    .keyboardType(.numberPad)
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: true)
                                    
                                    Text("reps")
                                    
                                    Spacer()
                                    
                                    Toggle(isOn: Binding(
                                        get: { manager.completedSets.contains("\(exercise.id)-\(index)") },
                                        set: { manager.handleSetCompletion(exercise, index, $0) }
                                    )) {
                                        Text("Set \(index + 1)")
                                    }
                                    .toggleStyle(iOSCheckboxToggleStyle())
                                }
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 25)
                }
            }
            .navigationTitle(routine.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("End Workout") {
                        manager.endWorkout()
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = false
                    }
                }
            }
            .onAppear {
                if !manager.isWorkoutInProgress {
                    manager.startWorkout(routine: routine)
                }
            }
        }
    }
}
