//
//  EditRoutineView.swift
//  Newton Notes
//
//  Created by James Gasek on 11/7/24.
//

import SwiftUI

struct EditRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var routine: Routine
    
    var body: some View {
        List {
            Section("Exercises") {
                ForEach(routine.exercises, id: \.template.name) { exercise in
                    NavigationLink {
                        ExerciseDetailView(exercise: exercise)
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
                .onMove { from, to in
                    print("Before move:", routine.exercises.map { $0.template.name })
                    
                    // Create a new array, make the change, and assign it back
                    var newArray = Array(routine.exercises)
                    newArray.move(fromOffsets: from, toOffset: to)
                    routine.exercises = newArray
                    
                    print("After move:", routine.exercises.map { $0.template.name })
                    
                    do {
                        try modelContext.save()
                        print("Save completed")
                    } catch {
                        print("Save failed:", error)
                    }
                }
            }
        }
        .navigationTitle(routine.name)
        .toolbar {
            EditButton()
        }
    }
}
