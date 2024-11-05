//
//  WorkoutHistoryView.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/2/24.
//

import Foundation
import SwiftUI
import SwiftData

// History View
struct WorkoutHistoryView: View {
    @Query private var workouts: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink {
//                        WorkoutDetailView(workout: workout)
                    } label: {
                        WorkoutHistoryRow(workout: workout)
                    }
                }
                .onDelete(perform: deleteWorkouts)
            }
            .navigationTitle("Workout History")
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }
}
