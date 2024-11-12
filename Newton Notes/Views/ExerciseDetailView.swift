//
//  ExersizeDetailView.swift
//  Newton Notes
//
//  Created by James Gasek on 11/6/24.
//

import SwiftUI

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var exercise: Exercise
    @FocusState private var focusedField: Bool
    
    var body: some View {
        List {
            Section("SETS") {
                ForEach(exercise.sets.indices, id: \.self) { index in
                    HStack {
                        Text("Set \(index + 1)")
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        TextField("0", value: $exercise.sets[index].weight, format: .number)
                        
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField)
                            .frame(width: 60)
                        
                        Text("lbs")
                            .foregroundStyle(.gray)
                            .frame(width: 30, alignment: .leading)
                        
                        TextField("0", value: $exercise.sets[index].reps, format: .number)
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
        exercise.sets.append(ExerciseSet())
    }
    
    private func removeLastSet() {
        if !exercise.sets.isEmpty {
            exercise.sets.removeLast()
        }
    }
    
    private func saveExercise() {
        try? modelContext.save()
        dismiss()
    }
}

//
//
//#Preview {
//    ExersizeDetailView()
//}
