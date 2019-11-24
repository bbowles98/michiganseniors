//
//  VoteReadyView.swift
//  eLect2
//
//  Created by Madelyn Rycenga on 11/8/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit

class VoteReadyView: UIView {
    let nibName = "voteReadyView"
    var contentView: UIView?

    @IBOutlet weak var host: UILabel!
    @IBOutlet weak var name: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

