//
//  CastVoteViewController.swift
//  eLect2
//
//  Created by Madelyn Rycenga on 11/4/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import Foundation
import UIKit
var choices: [String] = []
var selectedChoice = 0

class CastVoteViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view.
        getURL = "http://204.48.30.178/vote?code=532932"
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
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
                print(json)
                self.ballotItems = json["ballot_items"] as! [String: Any]
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
    var ballotItems = [:] as [String: Any]
    var question = ""
    
    func createBallot() {
        question = ballotItems["question"].debugDescription
        choices = ballotItems["choices"] as! [String]
        Question.text = question
        
    }
    
    @IBOutlet weak var viewChoices: BallotTableView!
    @IBOutlet weak var Question: UILabel!
    @IBAction func onClickCastVote(_ sender: UIBarButtonItem) {
        // Package information into JSON
        let option = choices[selectedChoice]
        let json: [String: Any] = ["election_id": self.electionID, "candidate": option
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
        
        performSegue(withIdentifier: "nextView", sender: self)
    }
}

class BallotTableView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = choices[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChoice = indexPath.row
    }
}
