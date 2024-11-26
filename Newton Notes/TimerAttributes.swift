import Foundation
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    var initialSeconds: Int
    
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var secondsRemaining: Int
    }
}
