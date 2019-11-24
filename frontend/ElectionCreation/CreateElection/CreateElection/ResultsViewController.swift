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
    var ballotItems = [:] as [String: Any]
    var electionName:String = ""
    var total:Int = -1
    var electionID:String = ""
    var token:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Need to add API request here
        // Do any additional setup after loading the view.
        getURL = "http://204.48.30.178/results/?election_id=" + electionID
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
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
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
            
        electionName = results["name"] as! String
        live = (results["live"] != nil)
        total = results["total_votes"] as! Int
        
        var candidate = ballotItems[indexPath.row]
        var votes = ballotItems[indexPath.row]
        cell.optionName?.text = (candidate as! String)
        cell.optionVotes?.text = String(ballotItems["candidate"])
        cell.optionPer?.text = String(Int(votes)!/Int(total) * 100) + "%"

        return cell

    }
    
    // if the poll is closed, say that poll is closed
    // otherwise, say live analytics and you need to figure out how to loop to continuously be able to check for updates in results
}

