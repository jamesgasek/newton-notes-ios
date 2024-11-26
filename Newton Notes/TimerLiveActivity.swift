import SwiftUI
import WidgetKit
import ActivityKit

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // Live Activity UI (notification center and dynamic island expanded)
            VStack(spacing: 2) {
                HStack {
                    Label("Rest Timer", systemImage: "timer")
                        .font(.headline)
                    Spacer()
                    Text(timerText(for: context.state.secondsRemaining))
                        .font(.title2.monospacedDigit())
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                ProgressView(value: Double(context.attributes.initialSeconds - context.state.secondsRemaining), total: Double(context.attributes.initialSeconds))
                    .tint(.blue)
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .activityBackgroundTint(.black.opacity(0.8))
            .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label("Rest Timer", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerText(for: context.state.secondsRemaining))
                        .font(.title2)
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: Double(context.state.secondsRemaining), total: Double(context.attributes.initialSeconds))
                        .tint(.blue)
                }
            } compactLeading: {
                // Compact leading UI (Dynamic Island)
                Label {
                    Text(timerText(for: context.state.secondsRemaining))
                } icon: {
                    Image(systemName: "timer")
                }
                .font(.caption2)
            } compactTrailing: {
                // Compact trailing UI (Dynamic Island)
                Text(timerText(for: context.state.secondsRemaining))
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                // Minimal UI (Dynamic Island)
                Image(systemName: "timer")
            }
        }
    }
    
    private func timerText(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
