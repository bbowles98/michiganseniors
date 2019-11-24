//
//  ResultTableCell.swift
//  ViewResults
//
//  Created by Grace Economou on 11/21/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit

class ResultTableCell: UITableViewCell {
    
    @IBOutlet weak var optionName: UILabel!
    @IBOutlet weak var optionVotes: UILabel!
    @IBOutlet weak var optionPer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
