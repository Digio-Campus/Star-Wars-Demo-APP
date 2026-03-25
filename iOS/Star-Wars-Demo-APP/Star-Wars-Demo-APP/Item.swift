//
//  Item.swift
//  Star-Wars-Demo-APP
//
//  Created by valero on 25/3/26.
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
