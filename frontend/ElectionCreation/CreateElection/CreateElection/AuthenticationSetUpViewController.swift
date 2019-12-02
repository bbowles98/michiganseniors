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
        
        let json: [String: Any] = [
            "election_id": self.electID,
            "max_voters": numVoters,
            "email_domain": allowedDomain
        ]
              
              
      let jsonData = try? JSONSerialization.data(withJSONObject: json)
      var request = URLRequest(url: URL(string: "http://204.48.30.178/addElectionRestrictions/")!)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      
      request.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
      print("ballot token:")
      print(token)
      request.httpMethod = "POST"
      request.httpBody = jsonData
      //print("jsonData 51: ")
      
      if let string = String(bytes: jsonData!, encoding: .utf8) {
          print(string)
      }
      
      //async error handling
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let _ = data, error == nil else {
              
              print("NETWORKING ERROR")
              return
          }
          
          if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
              
              print(response.debugDescription)
              print("HTTP STATUS: \(httpStatus.statusCode)")
              return
          }
          do {
              let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]

          }
          catch let error as NSError {
              print(error)
          }
      }
      //run the previous copule lines of code in a seperate thread
        task.resume()
        
        performSegue(withIdentifier: "ToAddOption", sender: (Any).self)
        
    }
    @IBAction func onBack(_ sender: Any) {
        performSegue(withIdentifier: "BackToCreate", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToAddOptions" {
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
