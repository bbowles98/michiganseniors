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
        questionTextLabel?.text = electionQuestion
        self.createBallot()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var electionQuestion:String = ""
    var choices: [String] = []
    var token:String = ""
    var election_id:String = ""
    
    @IBAction func onPublish(_ sender: Any) {
        
        print("printing election_id to test it: ")
        print(self.election_id)
        let json: [String: Any] = [
            "election_id": self.election_id,
            "ballot_items": [
                ["question" : self.electionQuestion, "choices" : self.choices]
            ]
        ]
              
              print("questions: " + electionQuestion)
              
              let jsonData = try? JSONSerialization.data(withJSONObject: json)
              var request = URLRequest(url: URL(string: "http://204.48.30.178/ballot/")!)
              request.addValue("application/json", forHTTPHeaderField: "Content-Type")
              request.addValue("application/json", forHTTPHeaderField: "Accept")
              
              request.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
              print("ballot token:")
              print(token)
              request.httpMethod = "POST"
              request.httpBody = jsonData
              print("jsonData 51: ")
              
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
        performSegue(withIdentifier: "Created", sender: (Any).self)
    }
    
    @IBOutlet weak var questionTextLabel: UILabel!
    
    func createBallot() {
        
        //print("printing whether it should be light mode or not")
        //print("AAHHHHHHHHHHH")
        //print(isLight)
        var buttonY = 175
        print("the voting choices to preview are: ")
        print(choices)
        for choice in choices{
            print(choice)
            let optionButton = UIButton(frame: CGRect(x: 80, y: buttonY, width: 250, height: 60))
            buttonY = buttonY + 100
            optionButton.layer.cornerRadius = 10
            if isLight == false {
                optionButton.backgroundColor = UIColor.systemGray
            } else {
                optionButton.backgroundColor = UIColor.systemTeal
            }
            optionButton.setTitleColor(UIColor.white, for: UIControl.State.normal )
            optionButton.setTitle(choice, for: UIControl.State.normal)
            optionButton.isEnabled = false
            optionButton.addTarget(self, action: Selector(("selectedChoice:")), for: UIControl.Event.touchUpInside)
            self.view.addSubview(optionButton)
        }
    }
}
