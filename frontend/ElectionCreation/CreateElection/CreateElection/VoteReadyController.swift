//
//  VoteReadyController.swift
//  eLect2
//
//  Created by Madelyn Rycenga on 11/4/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit

class VoteReadyController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        name.text = electionName
        Host.text = hostName
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionName:String = ""
    var hostName:String = ""
    var electionID:String = ""
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var Host: UILabel!
    
    @IBAction func onClickContinue(_ sender: Any) {
        performSegue(withIdentifier: "Vote", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CastVoteViewController
        {
            let vc = segue.destination as? CastVoteViewController
            vc!.electionID = electionID
        }
    }
}

