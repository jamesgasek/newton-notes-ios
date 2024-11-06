import SwiftUI
import SwiftData

// Main tab view container
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {

            RoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "dumbbell.fill")
                }
            
            WorkoutHistoryView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
    }
}





// Helper Views
struct WorkoutHistoryRow: View {
    let workout: Routine
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

