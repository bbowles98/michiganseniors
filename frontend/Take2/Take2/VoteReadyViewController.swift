//
//  VoteReadyControllerViewController.swift
//  eLect2
//
//  Created by Madelyn Rycenga on 11/8/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import UIKit

class VoteReadyViewController: UIViewController {

    @IBOutlet var voteReadyView: VoteReadyView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        voteReadyView.name?.text = electionName
        voteReadyView.host?.text = hostName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionName:String = ""
    var hostName:String = ""
    var electionIDpassed:String = ""
    
}
