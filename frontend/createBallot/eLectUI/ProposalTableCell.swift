//
//  ProposalTableCell.swift
//  eLectUI
//
//  Created by Grace Economou on 11/4/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit

class ProposalTableCell: UITableViewCell {
    
    @IBOutlet weak var proposalName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
