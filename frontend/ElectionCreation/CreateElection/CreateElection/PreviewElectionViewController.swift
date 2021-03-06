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
    var isLight:Bool = false
    @IBAction func onBackToAdd(_ sender: Any) {
        self.performSegue(withIdentifier: "BackToAdd", sender: (Any).self)
    }
    
    @IBAction func onPublish(_ sender: Any) {
        
        print("printing election_id to test it: ")
        print(self.election_id)
        let json: [String: Any] = [
            "election_id": self.election_id,
            "ballot_items": [
                ["question" : self.electionQuestion, "choices" : self.choices]
            ],
            "is_light": String(self.isLight)
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
                    print(json)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "Created", sender: (Any).self)
                    }

                  }
                  catch let error as NSError {
                      print(error)
                  }
              }
        task.resume()
    }
    
    @IBOutlet weak var questionTextLabel: UILabel!
    
    func createBallot() {
        var buttonY = 175
        print("the voting choices to preview are: ")
        print(choices)
        for choice in choices{
            print(choice)
            let optionButton = UIButton(frame: CGRect(x: 80, y: buttonY, width: 250, height: 60))
            buttonY = buttonY + 80
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ElectionViewController
        {
            let vc = segue.destination as? ElectionViewController
            vc!.token = self.token
            vc!.electionQuestion = self.electionQuestion
            vc!.answers = self.choices
            vc!.electID = self.election_id
            vc!.isLight = self.isLight
        }
    }
}
