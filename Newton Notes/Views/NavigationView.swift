import SwiftUI
import SwiftData

struct NavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutManager.self) private var workoutManager
    
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
        .overlay(
            Group {
                if workoutManager.timeRemaining > 0 {
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            Text(timeString(from: workoutManager.timeRemaining))
                                .font(.system(.title2, design: .monospaced))
                                .foregroundColor(workoutManager.timeRemaining <= 15 ? .red : .primary)
                                .padding(.leading)
                            
                            Spacer()
                            
                            Button(action: {
                                workoutManager.stopTimer()
                            }) {
                                HStack(spacing: 4) {
                                    Text("Skip")
                                    Image(systemName: "forward.fill")
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                            }
                        }
                        .frame(height: 44)
                        .background(Color(.systemBackground).opacity(0.95))
                    }
                    .transition(.move(edge: .bottom))
                }
            },
            alignment: .bottom
        )
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
