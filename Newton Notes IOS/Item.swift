//
//  Item.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/1/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
