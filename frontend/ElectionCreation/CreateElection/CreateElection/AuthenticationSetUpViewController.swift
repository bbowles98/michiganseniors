//
//  AuthenticationSetUpViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/26/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit

class AuthenticationSetUpViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    @IBOutlet weak var numVoters: UITextField!
    @IBOutlet weak var allowedDomain: UITextField!
    
}
