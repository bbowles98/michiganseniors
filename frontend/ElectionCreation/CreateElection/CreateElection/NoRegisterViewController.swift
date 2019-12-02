//
//  NoRegisterViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 12/2/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit

class NoRegisterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionName:String = ""
    var electionID:String = ""
    var token:String = ""
    var host:String = ""
    
    @IBAction func onExit(_ sender: Any) {
        performSegue(withIdentifier: "BackFromNotReg", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VoteReadyViewController
        {
            let vc = segue.destination as? VoteReadyViewController
            vc!.electionName = electionName
            vc!.electionIDpassed = electionID
            vc!.token = token
            vc!.hostName = host
        }
    }
}
