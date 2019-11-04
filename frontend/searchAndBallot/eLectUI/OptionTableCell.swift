//
//  OptionTableCell.swift
//  eLectUI
//
//  Created by Grace Economou on 11/3/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit

class OptionTableCell: UITableViewCell {
    
    @IBOutlet weak var optionName: UILabel!
    @IBOutlet weak var optionInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
