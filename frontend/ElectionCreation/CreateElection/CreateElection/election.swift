//
//  createElect.swift
//  Create_Election
//
//  Created by Madelyn Rycenga on 11/2/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit
class Election {
    var host: String
    var name: String
    var startDate: UIDatePicker
    var endDate: UIDatePicker
    var isPublic: Bool
    
    
    init(host: String, name: String, startDate: UIDatePicker, endDate: UIDatePicker, isPublic: Bool) {
        self.host = host
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.isPublic = isPublic
    }
}
