//
//  User.swift
//  Chatter
//
//  Created by Kevin Lee on 11/2/19.
//  Copyright © 2019 Kevin Lee. All rights reserved.
//
import UIKit
class User {
    var fullname: String
    var email: String
    var password: String
    
    init(fullname: String, email: String, password: String) {
        self.fullname = fullname
        self.email = email
        self.password = password
    }
}
