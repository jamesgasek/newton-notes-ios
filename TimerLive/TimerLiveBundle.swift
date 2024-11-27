//
//  TimerLiveBundle.swift
//  TimerLive
//
//  Created by James Gasek on 11/27/24.
//

import WidgetKit
import SwiftUI

@main
struct TimerLiveBundle: WidgetBundle {
    var body: some Widget {
        TimerLive()
        TimerLiveControl()
        TimerLiveLiveActivity()
    }
}
