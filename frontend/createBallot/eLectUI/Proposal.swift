//
//  Proposal.swift
//  eLectUI
//
//  Created by Grace Economou on 11/4/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit

class Proposal {
    var question: String
    var choices = [votingOption]()
    
    init(question: String, choices: [votingOption]) {
        self.question = question
        self.choices = choices
    }
}
