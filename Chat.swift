//
//  Chat.swift
//  Chatter
//
//  Created by Kevin Lee on 9/20/19.
//  Copyright © 2019 Kevin Lee. All rights reserved.
//

import Foundation
import UIKit
class Chatt {
    var username: String
    var message: String
    var timestamp: String
    
    init(username: String, message: String, timestamp: String) {
        self.username = username
        self.message = message
        self.timestamp = timestamp
    }
}

