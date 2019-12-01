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
    var token:String = ""
    var electID:String = ""
    
    @IBAction func onNext(_ sender: Any) {
        performSegue(withIdentifier: "ToAddOption", sender: (Any).self)
    }
    @IBAction func onBack(_ sender: Any) {
        performSegue(withIdentifier: "BackToCreate", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToAddOption" {
        print("Going to add voting options: " + token)
        let navVC = segue.destination as? UINavigationController
        let vc = navVC?.viewControllers.first as? ElectionViewController
        vc!.token = token
        vc!.electID = electID
    }
    else if segue.identifier == "BackToCreate" {
        print("Going Back: " + token)
        let navVC = segue.destination as? UINavigationController
        let vc = navVC?.viewControllers.first as? CreateElectViewController
        vc!.token = token
        }
    }
}
