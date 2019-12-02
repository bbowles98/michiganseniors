//
//  CastVoteViewController.swift
//  eLect2
//
//  Created by Madelyn Rycenga on 11/4/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit


class CastVoteViewController: UIViewController {
    
    @IBOutlet weak var question: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view.
        getURL = "http://204.48.30.178/vote/?election_id=" + electionID
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //token_response here is the same token_response that is created during Signin. (See line 76)
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
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: [[String: [String]]]]
                print("The json received is:")
                print(json)
                //print(json.debugDescription)
                self.ballotItems = json["ballot"]!
                self.createBallot()
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
    
    var electionID:String = ""
    var getURL:String = ""
    var electionName:String = ""
    var ballotItems:[[String: [String]]] = [[:]]
    var questionText = ""
    var choices: [String] = []
    var chosen = ""
    var token:String = ""
    //var token_response = ""
    
    func createBallot() {
        for dict in ballotItems {
            for (question, options) in dict {
                questionText = question
                choices = options
            }
        }
        DispatchQueue.main.async {
            self.question.text = self.questionText
            var buttonY = 175
            print("the voting choices to preview are: ")
            print(self.choices)
            for choice in self.choices {
                print(choice)
                let optionButton = UIButton(frame: CGRect(x: 80, y: buttonY, width: 250, height: 60))
                buttonY = buttonY + 100
                optionButton.layer.cornerRadius = 10
                optionButton.backgroundColor = UIColor.systemTeal
                optionButton.setTitleColor(UIColor.white, for: UIControl.State.normal )
                optionButton.setTitleColor(UIColor.black, for: .highlighted)
                optionButton.setTitle(choice, for: UIControl.State.normal)
                optionButton.isEnabled = true
                optionButton.addTarget(self, action: #selector(self.voteSelected(_:)), for: .touchUpInside)
                optionButton.showsTouchWhenHighlighted = true
                //optionButton.addTarget(self, action: Selector(("selectedChoice:")), for: UIControl.Event.touchUpInside)
                self.view.addSubview(optionButton)
            }
        }
    }
    
    @IBAction func voteSelected(_ sender: UIButton){
        chosen = sender.titleLabel!.text!
        print("chosen option:")
        print(chosen)
    }
    
    func selectedChoice(sender: Any){
        chosen = (sender as AnyObject).titleLabel!.text!
    }

    
    @IBAction func onClickCastVote(_ sender: Any) {
        // Package information into JSON
        let json: [String: Any] = ["election_id": self.electionID, "candidate": chosen
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url:
            URL(string: "http://204.48.30.178/cast/")!)
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
        }
        task.resume()
        performSegue(withIdentifier: "ToVoteComplete", sender: (Any).self)
    }
}
