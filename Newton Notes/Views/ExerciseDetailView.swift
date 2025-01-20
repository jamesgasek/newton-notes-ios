// ExerciseDetailView.swift
import SwiftUI

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var exercise: Exercise
    @FocusState private var focusedField: Bool
    @EnvironmentObject private var preferenceManager: PreferenceManager
    
    var body: some View {
        List {
            Section("SETS") {
                ForEach(exercise.sortedSets.indices, id: \.self) { index in
                    HStack {
                        Text("Set \(index + 1)")
                        
                        Spacer()
                        
                        let set = exercise.sortedSets[index]
                        
                        TextField("0", value: Binding(
                            get: { set.weight },
                            set: {
                                set.weight = $0
                                try? modelContext.save()
                            }
                        ), format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField)
                            .frame(width: 60)
                        
                        Text(preferenceManager.weightUnit)
                            .foregroundStyle(.gray)
                            .frame(width: 30, alignment: .leading)
                        
                        TextField("0", value: Binding(
                            get: { set.reps },
                            set: {
                                set.reps = $0
                                try? modelContext.save()
                            }
                        ), format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField)
                            .frame(width: 60)
                        
                        Text("reps")
                            .foregroundStyle(.gray)
                            .frame(width: 40, alignment: .leading)
                    }
                }
            }
            
            Section {
                Button(action: addSet) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add Set")
                            .foregroundColor(.blue)
                    }
                }
                
                if !exercise.sets.isEmpty {
                    Button(action: removeLastSet) {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                            Text("Remove Last Set")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Section("Rest Time (Seconds)") {
                TextField("90", value: $exercise.restTime, format: .number)
                    .focused($focusedField)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle(exercise.template.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveExercise()
                }
            }
            
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        focusedField = false
                    }
                }
            }
        }
    }
    
    private func addSet() {
        let newSortOrder = exercise.sets.map(\.sortOrder).max() ?? -1
        let newSet = ExerciseSet(sortOrder: newSortOrder + 1)
        exercise.sets.append(newSet)
        try? modelContext.save()
    }
    
    private func removeLastSet() {
        if !exercise.sets.isEmpty {
            let lastSet = exercise.sortedSets.last
            if let setToRemove = lastSet {
                exercise.sets.removeAll { $0.sortOrder == setToRemove.sortOrder }
                try? modelContext.save()
            }
        }
    }
    
    private func saveExercise() {
        try? modelContext.save()
        dismiss()
    }
}

