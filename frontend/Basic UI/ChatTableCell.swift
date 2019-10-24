//
//  ChatTableCell.swift
//  Chatter
//
//  Created by Kevin Lee on 9/20/19.
//  Copyright © 2019 Kevin Lee. All rights reserved.
//

import Foundation
import UIKit
class ChattTableCell: UITableViewCell {
    
@IBOutlet weak var usernameLabel: UILabel!
@IBOutlet weak var timestampLabel: UILabel!
@IBOutlet weak var messageLabel: UILabel!
    
override func awakeFromNib() {
    super.awakeFromNib()
// Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
