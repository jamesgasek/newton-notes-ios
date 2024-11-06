import SwiftUI


struct WorkoutView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @State private var completedSets = Set<String>()  // Track completed sets
    @State private var timeRemaining: Int = 0  // Timer countdown in seconds
    @State private var timer: Timer?
    @State private var activeExercise: Exercise?
    @State private var activeSetIndex: Int?
    
    var body: some View {
        NavigationStack {
            VStack {
                // Timer display
                if timeRemaining > 0 {
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(timeRemaining <= 15 ? .red : .primary)
                        .padding()
                }
                
                List {
                    ForEach(routine.exercises) { exercise in
                        Section(header: Text(exercise.template.name).font(.headline)) {
                            ForEach(Array(exercise.sets.enumerated()), id: \.offset) { index, set in
                                SetRow(
                                    exercise: exercise,
                                    setIndex: index,
                                    set: set,
                                    isCompleted: completedSets.contains(setIdentifier(exercise, index)),
                                    isLastSet: isLastSet(exercise, index),
                                    onComplete: { completed in
                                        handleSetCompletion(exercise, index, completed)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle(routine.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("End Workout") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Helper functions
    private func setIdentifier(_ exercise: Exercise, _ setIndex: Int) -> String {
        "\(exercise.id)-\(setIndex)"
    }
    
    private func isLastSet(_ exercise: Exercise, _ setIndex: Int) -> Bool {
        if let lastExercise = routine.exercises.last,
           lastExercise.id == exercise.id,
           setIndex == exercise.sets.count - 1 {
            return true
        }
        return false
    }
    
    private func handleSetCompletion(_ exercise: Exercise, _ setIndex: Int, _ completed: Bool) {
        let identifier = setIdentifier(exercise, setIndex)
        
        if completed {
            completedSets.insert(identifier)
            if !isLastSet(exercise, setIndex) {
                startTimer()
                activeExercise = exercise
                activeSetIndex = setIndex
            }
        } else {
            completedSets.remove(identifier)
            if activeExercise?.id == exercise.id && activeSetIndex == setIndex {
                stopTimer()
            }
        }
    }
    
    private func startTimer() {
        stopTimer()  // Stop any existing timer
        timeRemaining = 90  // 90 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// Separate view for each set row
struct SetRow: View {
    let exercise: Exercise
    let setIndex: Int
    let set: ExerciseSet
    let isCompleted: Bool
    let isLastSet: Bool
    let onComplete: (Bool) -> Void
    
    @State private var weight: Double
    @State private var reps: Int
    
    init(exercise: Exercise, setIndex: Int, set: ExerciseSet, isCompleted: Bool, isLastSet: Bool, onComplete: @escaping (Bool) -> Void) {
        self.exercise = exercise
        self.setIndex = setIndex
        self.set = set
        self.isCompleted = isCompleted
        self.isLastSet = isLastSet
        self.onComplete = onComplete
        _weight = State(initialValue: set.weight)
        _reps = State(initialValue: set.reps)
    }
    
    var body: some View {
        HStack {
            TextField("Weight", value: $weight, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
                .keyboardType(.decimalPad)
            
            Text("lbs")
            
            TextField("Reps", value: $reps, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 50)
                .keyboardType(.numberPad)
            
            Text("reps")
            
            Spacer()
            
            Toggle(isOn: Binding(
                get: { isCompleted },
                set: { onComplete($0) }
            )) {
                Text("Set \(setIndex + 1)")
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            
        }
//        .disabled(isCompleted)
    }
}
