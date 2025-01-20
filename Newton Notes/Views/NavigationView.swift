import SwiftUI
import SwiftData

struct NavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutManager.self) private var workoutManager
    
    private let timerBarHeight: CGFloat = 44
    
    init() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Apply the tab bar appearance settings
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView {
            RoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "dumbbell.fill")
                }
                .safeAreaInset(edge: .bottom) {
                    if workoutManager.currentRoutine != nil {
                        Spacer().frame(height: timerBarHeight)
                    }
                }
            
            WorkoutHistoryView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
                .safeAreaInset(edge: .bottom) {
                    if workoutManager.currentRoutine != nil {
                        Spacer().frame(height: timerBarHeight)
                    }
                }
            
            UtilitiesView()
                .tabItem {
                    Label("Utilities", systemImage: "wrench.and.screwdriver")
                }
                .safeAreaInset(edge: .bottom) {
                    if workoutManager.currentRoutine != nil {
                        Spacer().frame(height: timerBarHeight)
                    }
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .safeAreaInset(edge: .bottom) {
                    if workoutManager.currentRoutine != nil {
                        Spacer().frame(height: timerBarHeight)
                    }
                }
            
        }
        .tint(.blue)
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Text(workoutManager.currentRoutine?.name ?? "No routine started")
                        .padding(.leading)
                    
                    if workoutManager.timeRemaining > 0 {
                        Text(timeString(from: workoutManager.timeRemaining))
                            .font(.system(.title2, design: .monospaced))
                            .foregroundColor(workoutManager.timeRemaining <= 15 ? .red : .primary)
                            .padding(.leading)

                        Spacer()
                        
                        Button(action: {
                            workoutManager.skipCurrentPeriod()
                        }) {
                            HStack(spacing: 4) {
                                Text("Skip Rest")
                                Image(systemName: "forward.fill")
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                        }
                    } else {
                        Spacer()
                    }
                }
                .ignoresSafeArea(.keyboard)
                .frame(height: timerBarHeight)
                .background(Color(.systemBackground).opacity(0.95))
            }
            .ignoresSafeArea(.keyboard)
            .padding(.bottom, 49)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
