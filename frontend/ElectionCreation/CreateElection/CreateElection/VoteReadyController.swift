//
//  VoteReadyControllerViewController.swift
//  eLect2
//
//  Created by Madelyn Rycenga on 11/8/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import UIKit

class VoteReadyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        name?.text = electionName
        host?.text = hostName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionName:String = ""
    var hostName:String = ""
    var electionIDpassed:String = ""
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var host: UILabel!
    @IBAction func onVote(_ sender: Any) {
        // On the click off the vote button, segue to ballot
        self.performSegue(withIdentifier: "ToBallot", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CastVoteViewController
        {
            let vc = segue.destination as? CastVoteViewController
            vc!.electionName = electionName
            vc!.electionID = electionIDpassed
        }
    }
}

