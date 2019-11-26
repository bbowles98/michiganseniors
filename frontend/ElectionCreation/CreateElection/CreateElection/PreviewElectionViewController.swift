//
//  PreviewElectionViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/25/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit

class PreviewElectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                print(json.debugDescription)
                self.ballotItems = json["ballot"] as! [String: Any]
                self.createBallot()
            }
           catch let error as NSError {
            print(error)
           }
        }
        task.resume()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionID:String = ""
    var getURL:String = ""
    var electionName:String = ""
    var ballotItems = [:] as [String: Any]
    var questionText = ""
    var choices: [String] = []
    var chosen = ""
    var token:String = ""
    
    @IBOutlet weak var questionLabel: UILabel!
    
    
    func createBallot() {
        questionText = ballotItems["question"].debugDescription
        choices = ballotItems["choices"] as! [String]
        questionLabel!.text = questionText
        
        var buttonY = 0
        for choice in choices{
            let optionButton = UIButton(frame: CGRect(x: 50, y: buttonY, width: 250, height: 30))
            buttonY = buttonY + 50
            optionButton.layer.cornerRadius = 10
            optionButton.backgroundColor = UIColor.darkGray
            optionButton.titleLabel?.text = choice
            optionButton.addTarget(self, action: Selector(("selectedChoice:")), for: UIControl.Event.touchUpInside)
            self.view.addSubview(optionButton)
        }
    }
    
    func selectedChoice(sender: UIButton!){
        chosen = sender.titleLabel!.text!
    }
}
