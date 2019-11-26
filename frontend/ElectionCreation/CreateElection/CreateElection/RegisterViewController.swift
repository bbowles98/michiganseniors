//
//  RegisterViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/26/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionName:String = ""
    var electionID:String = ""
    var token:String = ""
    
    @IBAction func onBack(_ sender: Any) {
        performSegue(withIdentifier: "BackToReady", sender: (Any).self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VoteReadyViewController
        {
            let vc = segue.destination as? VoteReadyViewController
            vc!.electionName = electionName
            vc!.electionIDpassed = electionID
            vc!.token = token
        }
    }
}
