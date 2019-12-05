//
//  PrivateRegisterViewController.swift
//  CreateElection
//
//  Created by Grace Economou on 12/2/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit

class PrivateRegisterViewController: UIViewController {
    
    var electionName:String = ""
    var hostName:String = ""
    var electionIDpassed:String = ""
    var token:String = ""
    var canViewResults = false
    var isRegistered = false
    
    @IBOutlet weak var passcodeEntry: UITextField!
    @IBAction func onRegister(_ sender: Any) {
        let getURL = "http://204.48.30.178/register/"
        print(self.electionIDpassed)
        let json: [String: Any] = ["election_id": self.electionIDpassed, "passcode": self.passcodeEntry.text]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request)
               { data, response, error in
                   guard let _ = data, error == nil else {
                       print("NETWORKING ERROR")
                       return}
                   if let httpStatus = response as? HTTPURLResponse,
                       httpStatus.statusCode != 200 {
                       print("HTTP STATUS: \(httpStatus.statusCode)")
                       return}
                   do {
                        let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                        print(json.debugDescription)
                        print("THIS", json)
                        
                    let temp = json["success"] as! Bool
                        if !temp {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Registration Error",
                                message: "Invalid passcode.",
                                preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                                    self.present(alertController, animated: true, completion: nil)
                                
                                return
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "PrivateRegSuccess", sender: (Any).self)
                            }
                        }
                   }
                  catch let error as NSError {
                   print(error)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "PrivateRegFail", sender: (Any).self)
                    }
                  }
               }
               task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "PrivateRegSuccess") {
            let vc = segue.destination as? RegisterViewController
            vc!.electionName = electionName
            vc!.electionID = electionIDpassed
            vc!.token = token
            vc!.host = hostName
        }
        else if (segue.identifier == "PrivateRegFail") {
            let vc = segue.destination as? NoRegisterViewController
            vc!.electionName = electionName
            vc!.electionID = electionIDpassed
            vc!.token = token
            vc!.host = hostName
        }
    }

}
