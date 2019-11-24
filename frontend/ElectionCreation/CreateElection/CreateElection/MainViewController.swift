//
//  MainViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/24/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//
import UIKit
import Foundation

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    var token:String = ""
    
    @IBAction func SearchSegue(_ sender: Any) {
        self.performSegue(withIdentifier: "ToSearch", sender: (Any).self)
    }
    @IBAction func CreateSegue(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ToCreate", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SearchViewController
        {
            let vc = segue.destination as? SearchViewController
            vc!.token = token
        }
        else if segue.destination is CreateElectViewController
        {
            let vc = segue.destination as? CreateElectViewController
            vc!.token = token
        }
    }
}
