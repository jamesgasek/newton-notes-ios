//
//  TimerWidgetLiveActivity.swift
//  TimerWidget
//
//  Created by James Gasek on 11/27/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

//struct TimerWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        var emoji: String
//    }
//
//    var name: String
//}

//struct TimerWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: TimerWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
import SwiftUI
import WidgetKit
import ActivityKit
import Foundation

struct TimerWidgetAttributes: ActivityAttributes {
    var initialSeconds: Int
    
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var secondsRemaining: Int
    }
}



struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerWidgetAttributes.self) { context in
            // Live Activity UI (notification center and dynamic island expanded)
            VStack(spacing: 2) {
                HStack {
                    Label("Rest Timer", systemImage: "timer")
                        .font(.headline)
//                        .foregroundColor(.white)
                    Spacer()
                    Text(timerText(for: context.state.secondsRemaining))
                        .font(.title2.monospacedDigit())
//                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                ProgressView(value: Double(context.attributes.initialSeconds - context.state.secondsRemaining), total: Double(context.attributes.initialSeconds))
                    .tint(.blue)
                    .padding(.horizontal)
            }
            .padding(.vertical, 20)
//            .activityBackgroundTint(.black.opacity(0.8))
            .activityBackgroundTint(Color(UIColor.systemBackground).opacity(0.8))
//            .activitySystemActionForegroundColor(.white)
            
        }
        dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label("Rest Timer", systemImage: "timer")
                        .font(.headline)
//                        .foregroundColor(.white)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerText(for: context.state.secondsRemaining))
                        .font(.title2)
//                        .foregroundColor(.white)
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
                }
                icon: {
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


extension TimerWidgetAttributes {
    fileprivate static var preview: TimerWidgetAttributes {
        TimerWidgetAttributes(initialSeconds: 90)
    }
}

extension TimerWidgetAttributes.ContentState {
    fileprivate static var smiley: TimerWidgetAttributes.ContentState {
//        TimerWidgetAttributes.ContentState(emoji: "😀")
        
        TimerWidgetAttributes.ContentState(endTime: Date.distantFuture, secondsRemaining: 90)
     }
     
     fileprivate static var starEyes: TimerWidgetAttributes.ContentState {
//         TimerWidgetAttributes.ContentState(emoji: "🤩")
         
         TimerWidgetAttributes.ContentState(endTime: Date.distantFuture, secondsRemaining: 10)
     }
}

#Preview("Notification", as: .content, using: TimerWidgetAttributes.preview) {
   TimerWidgetLiveActivity()
} contentStates: {
    TimerWidgetAttributes.ContentState.smiley
    TimerWidgetAttributes.ContentState.starEyes
}
