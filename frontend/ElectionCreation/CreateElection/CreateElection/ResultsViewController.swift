//
//  ViewController.swift
//  ViewResults
//
//  Created by Grace Economou on 11/21/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import UIKit


class ResultsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var results = [:] as [String: Any]
    var getURL:String = ""
    var live:Bool = false
<<<<<<< HEAD
    var votingOptions = [:] as [String: Any]
    var votes = [:] as [Int: Any]
=======
>>>>>>> 25c6b222da289f7e524589f6a49e0c166d458ceb
    var electionName:String = ""
    var total:Int = -1
    var electionID:String = ""
    var token:String = ""
    var candidates:[String] = []
    var voteCounts:[Int] = []
    @IBOutlet weak var electName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Need to add API request here
        // Do any additional setup after loading the view.
        self.electName.text = electionName
        getURL = "http://204.48.30.178/results/?election_id=" + electionID
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

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
                print(json)
                self.results = json["results"] as! [String: Any]
                self.candidates = self.results["candidates"] as! [String]
                self.voteCounts =  self.results["votes"] as! [Int]
                self.live = (self.results["live"] != nil)
                self.total = self.results["total_votes"] as! Int
            }
           catch let error as NSError {
            print(error)
           }
        }
        task.resume()
        
        // tableView.dataSource = self
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
        
<<<<<<< HEAD
        var candidate = votingOptions[indexPath.row]
        var numVotes = votes[indexPath.row]
        cell.optionName?.text = (candidate as! String)
        cell.optionVotes?.text = String(ballotItems["candidate"])
        cell.optionPer?.text = String(Int(votes)!/Int(total) * 100) + "%"
=======
        //let votes = voteCounts[Int(indexPath.row)]
        let candidate = ""
        cell.optionName!.text = candidate
        cell.optionVotes!.text = ""
        let percentage = ""//0/total * 100
        cell.optionPer!.text = percentage//String(percentage)
>>>>>>> 25c6b222da289f7e524589f6a49e0c166d458ceb

        return cell

    }
    
    // if the poll is closed, say that poll is closed
    // otherwise, say live analytics and you need to figure out how to loop to continuously be able to check for updates in results
}

