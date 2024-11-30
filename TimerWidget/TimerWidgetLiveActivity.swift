//
//  TimerWidgetLiveActivity.swift
//  TimerWidget
//
//  Created by James Gasek on 11/27/24.
//

import SwiftUI
import WidgetKit
import ActivityKit
import Foundation

struct TimerWidgetAttributes: ActivityAttributes {
    var name: String
    
    public struct ContentState: Codable, Hashable {
        var timerRange: ClosedRange<Date>
    }
}


struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerWidgetAttributes.self) { context in
            // Live Activity UI (notification center and dynamic island expanded)
            VStack(spacing: 2) {
                HStack {
                    Label(context.attributes.name, systemImage: "timer")
                        .font(.headline)
                    Spacer()
                    Text(timerInterval: context.state.timerRange)
                        .font(.title2.monospacedDigit())
                        .contentTransition(.numericText())
                        .multilineTextAlignment(.trailing)  // Add this
                }
                .padding(.horizontal)
                
            }
            .padding(.vertical, 20)
            .activityBackgroundTint(Color(UIColor.systemBackground).opacity(0.8))
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.name, systemImage: "timer")
                        .font(.headline)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.timerRange)
                        .font(.title2)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .multilineTextAlignment(.trailing)  // Add this
                }
                
                DynamicIslandExpandedRegion(.bottom) {
//                    ProgressView(value: progressValue(for: context.state.timerRange))
//                        .tint(context.state.isWorkout ? .green : .blue)
                }
            } compactLeading: {
                // Compact leading UI (Dynamic Island)
                Label {
                    Text(timerInterval: context.state.timerRange, showsHours: false)
                }
                icon: {
                    Image(systemName: "timer")
                }
                .font(.caption2)
            } compactTrailing: {
                // Compact trailing UI (Dynamic Island)
                Text(timerInterval: context.state.timerRange, showsHours: false)
                    .monospacedDigit()
                    .font(.caption2)
                    .contentTransition(.numericText())
                    .multilineTextAlignment(.trailing)  // Add this
            } minimal: {
                // Minimal UI (Dynamic Island)
                Image(systemName: "timer")
            }
        }
    }
}

// Preview helpers
extension TimerWidgetAttributes {
    fileprivate static var preview: TimerWidgetAttributes {
        TimerWidgetAttributes(name: "Rest Timer")
    }
}

extension TimerWidgetAttributes.ContentState {
    fileprivate static var rest: TimerWidgetAttributes.ContentState {
        TimerWidgetAttributes.ContentState(
            timerRange: Date()...(Date().addingTimeInterval(90))
        )
    }
     
    fileprivate static var workout: TimerWidgetAttributes.ContentState {
        TimerWidgetAttributes.ContentState(
            timerRange: Date()...(Date().addingTimeInterval(30))
        )
    }
}

#Preview("Notification", as: .content, using: TimerWidgetAttributes.preview) {
   TimerWidgetLiveActivity()
} contentStates: {
    TimerWidgetAttributes.ContentState.rest
    TimerWidgetAttributes.ContentState.workout
}
