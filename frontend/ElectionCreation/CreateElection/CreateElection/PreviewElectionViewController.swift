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
    
    @IBAction func onPublish(_ sender: Any) {
        let json: [String: Any] = [
            "election_id": election_id,
                 "ballot_items": [
                      [
                        "question": self.electionQuestion,
                        "choices" : self.choices
                      ]
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
              print("jsonData: ")
              
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
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var questionTextLabel: UILabel!
    
    func createBallot() {
        var buttonY = 0
        print("the voting choices to preview are: ")
        print(choices)
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
}
