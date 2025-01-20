//
//
//#Preview {
//    ExersizeDetailView()
//}
import Foundation
import SwiftUI
import SwiftData

struct RoutinesView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    @Query(sort: \Routine.sortOrder, animation: .default) private var routines: [Routine]
    @State private var showingAddRoutine = false
    @State private var selectedRoutine: Routine?
    @Environment(\.modelContext) private var modelContext
    
    init() {
        let descriptor = FetchDescriptor<Routine>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        _routines = Query(descriptor, animation: .default)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                           ForEach(routines) { routine in
                               RoutineRow(routine: routine, workoutManager: workoutManager, onSelect: {
                                   selectedRoutine = routine
                               })
                               .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                   NavigationLink {
                                       EditRoutineView(routine: routine)
                                   } label: {
                                       Text("Edit")
                                   }
                                   .tint(.blue)
                               }
                               .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                   Button(role: .destructive) {
                                       deleteRoutine(routine)
                                   } label: {
                                       Text("Delete")
                                   }
                                   .tint(.red)
                               }
                           }
                           .onMove { source, destination in
                               var updatedRoutines = routines
                               updatedRoutines.move(fromOffsets: source, toOffset: destination)
                               
                               // Update sort orders
                               for (index, routine) in updatedRoutines.enumerated() {
                                   routine.sortOrder = index
                               }
                               try? modelContext.save()
                           }
                       } footer: {
//                           Text("Swipe to edit / delete")
                       }
                   }
                   .navigationTitle("Routines")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddRoutine = true }) {
                        Label("Add Routine", systemImage: "plus")
                    }
                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    EditButton()
//                }
            }
            .sheet(isPresented: $showingAddRoutine) {
                AddRoutineView()
            }
            .alert("Begin this workout?", isPresented: Binding(
                get: { selectedRoutine != nil && workoutManager.currentRoutine == nil },
                set: { if !$0 { selectedRoutine = nil } }
            )) {
                NavigationLink(destination: {
                    if let routine = selectedRoutine {
                        WorkoutView(routine: routine, workoutManager: workoutManager)
                            .onAppear {
                                workoutManager.currentRoutine = routine
                            }
                    }
                }) {
                    Text("Let's go!")
                }
                Button("Cancel", role: .cancel) {
                    selectedRoutine = nil
                }
            }
            .alert("Workout in Progress", isPresented: Binding(
                get: { selectedRoutine != nil && workoutManager.currentRoutine != nil && selectedRoutine?.id != workoutManager.currentRoutine?.id },
                set: { if !$0 { selectedRoutine = nil } }
            )) {
                NavigationLink(destination: {
                    if let routine = selectedRoutine {
                        WorkoutView(routine: routine, workoutManager: workoutManager)
                            .onAppear {
                                workoutManager.currentRoutine = routine
                            }
                    }
                }) {
                    Text("End current and start new")
                }
                Button("Cancel", role: .cancel) {
                    selectedRoutine = nil
                }
            } message: {
                Text("There is already a routine in progress. Would you like to end that routine and start this one?")
            }
        }
    }
    
    private func deleteRoutine(_ routine: Routine) {
        withAnimation {
            modelContext.delete(routine)
            try? modelContext.save()
        }
    }
}

struct RoutineRow: View {
    let routine: Routine
    let workoutManager: WorkoutManager
    let onSelect: () -> Void
    
    var body: some View {
        if routine.id == workoutManager.currentRoutine?.id {
            NavigationLink(destination: WorkoutView(routine: routine, workoutManager: workoutManager)) {
                RowContent(routine: routine)
            }
        } else {
            Button(action: onSelect) {
                RowContent(routine: routine)
            }
            .buttonStyle(.plain)
        }
    }
}

struct RowContent: View {
   let routine: Routine
   
   var body: some View {
       VStack(alignment: .leading) {
           Text(routine.name)
               .font(.headline)
           Text("\(routine.exercises.count) \(routine.exercises.count == 1 ? "exercise" : "exercises")")
               .font(.subheadline)
               .foregroundColor(.secondary)
       }
       .frame(maxWidth: .infinity, alignment: .leading)
       .contentShape(Rectangle())
   }
}
