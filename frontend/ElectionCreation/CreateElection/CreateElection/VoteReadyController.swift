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
        
        let checkURL = "http://204.48.30.178/registeredElections/"
        
        var request1 = URLRequest(url:
            URL(string: checkURL)!)
        request1.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request1.addValue("application/json", forHTTPHeaderField: "Accept")

        print("cast vote token: " + token)
        request1.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
        request1.httpMethod = "GET"
        
        let task1 = URLSession.shared.dataTask(with: request1)
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
                print("result when asking if registered in id" + self.electionIDpassed)
                print(json.debugDescription)
                let elections = json["elections"] as! [Int]
                for elect in elections {
                    if (Int(elect) == Int(self.electionIDpassed)) {
                        self.isRegistered = true
                    }
                    else {
                        self.isRegistered = false
                    }
                }
            }
           catch let error as NSError {
            print(error)
           }
        }
        task1.resume()
        
        let getURL = "http://204.48.30.178/canViewResults/?election_id=" + electionIDpassed
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print("cast vote token: " + token)
        request.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
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
                print("Result of asking if i've voted in " + self.electionIDpassed)
                print(json.debugDescription)
                let result = json["can_view"] as! Bool
                if (result) {
                    self.canViewResults = true
                }
                DispatchQueue.main.async {
                    self.ViewResultButton.isHidden = !self.canViewResults
                    self.registrationButton.isHidden = self.isRegistered || self.canViewResults
                    self.voteButton.isHidden = ((self.canViewResults && self.isRegistered) || !self.isRegistered)
                    
                    print("can view register button:")
                    print(!self.isRegistered)
                    print("Can view result button:")
                    print(self.canViewResults)
                    print("can view vote button:")
                    print((!self.canViewResults && self.isRegistered))
                }
                
            }
           catch let error as NSError {
            print(error)
           }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionName:String = ""
    var hostName:String = ""
    var electionIDpassed:String = ""
    var token:String = ""
    var canViewResults = false
    var isRegistered = false
    var isPublic:Bool = true
    
    @IBOutlet weak var registrationButton: UIButton!
    @IBAction func onRegister(_ sender: Any) {
        
        let getURL = "http://204.48.30.178/isPublic/?election_id=" + self.electionIDpassed
        print(self.electionIDpassed)
        
        print(getURL)
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print("cast vote token: " + token)
        request.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                return}
            if let httpStatus = response as? HTTPURLResponse,
                httpStatus.statusCode != 200 {
                
                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            do {
                 let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                print(json.debugDescription)
                print(json)
                self.isPublic = json["public"] as! Bool
                if self.isPublic == true {
                    self.registerFunc()
                }
                else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toPrivateRegister", sender: (Any).self)
                    }
                }
            }
           catch let error as NSError {
                print(error)
           }
        }
        task.resume()
    }
    
    func registerFunc() {
        let getURL = "http://204.48.30.178/publicRegister/"
        print(self.electionIDpassed)
        let json: [String: Any] = ["election_id": self.electionIDpassed]
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
                    print(json)
                    DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ToRegister", sender: (Any).self)
                }
                    
               }
              catch let error as NSError {
               print(error)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "NoRegister", sender: (Any).self)
                }
              }
           }
           task.resume()
    }
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var host: UILabel!
    @IBOutlet weak var ViewResultButton: UIButton!
    @IBOutlet weak var voteButton: UIButton!
    @IBAction func onVote(_ sender: Any) {
        // On the click off the vote button, segue to ballot
        self.performSegue(withIdentifier: "ToBallot", sender: (Any).self)
    }
    @IBAction func onViewResult(_ sender: Any) {
        self.performSegue(withIdentifier: "ToResults", sender: (Any).self)
    }
    @IBAction func onSearch(_ sender: Any) {
        self.performSegue(withIdentifier: "BackToSearch", sender: (Any).self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CastVoteViewController
        {
            let vc = segue.destination as? CastVoteViewController
            vc!.electionName = electionName
            vc!.electionID = electionIDpassed
            vc!.token = token
            vc!.host = hostName
        }
        else if (segue.identifier == "ToResults") {
            let vc = segue.destination as? ResultsViewController
            vc!.electionName = electionName
            vc!.electionID = electionIDpassed
            vc!.token = token
            vc!.host = hostName
        }
        else if (segue.identifier == "ToRegister") {
            let vc = segue.destination as? RegisterViewController
            vc!.electionName = electionName
            vc!.electionID = electionIDpassed
            vc!.token = token
            vc!.host = hostName
        }
        else if (segue.identifier == "BackToSearch") {
            let vc = segue.destination as? SearchViewController
            vc!.token = token
            
        } else if (segue.identifier == "toPrivateRegister") {
            let vc = segue.destination as? PrivateRegisterViewController
            vc!.electionName = electionName
            vc!.electionIDpassed = electionIDpassed
            vc!.token = token
            vc!.hostName = hostName
        }
    }
}

