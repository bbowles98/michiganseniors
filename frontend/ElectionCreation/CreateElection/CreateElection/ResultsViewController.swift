//
//  ViewController.swift
//  ViewResults
//
//  Created by Grace Economou on 11/21/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import UIKit


class ResultsViewController: UIViewController {
    
    @IBOutlet weak var livePrint: UILabel!
    
    var results = [:] as [String: Any]
    var getURL:String = ""
    var live:Bool = false
    var electionName:String = ""
    var total:Float = -1
    var electionID:String = ""
    var token:String = ""
    var host:String = ""
    var candidates:[String] = []
    var voteCounts = [:] as [String: Any]
    @IBOutlet weak var electName: UILabel!
    
    @IBAction func onDone() {
        performSegue(withIdentifier: "ToElection", sender: (Any).self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Need to add API request here
        // Do any additional setup after loading the view.
        self.electName.text = electionName
        getURL = "http://204.48.30.178/results/?election_id=" + electionID
        print("Election id to view: " + electionID)
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.addValue("JWT " + token, forHTTPHeaderField: "Authorization")
        print("View Results Token: " + token)
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
                self.voteCounts =  self.results["ballot"] as! [String: Any]
                self.live = (self.results["live"] != nil)
                DispatchQueue.main.async {
                    if (self.live) {
                        self.livePrint.text = "Live Results"
                    }
                    else {
                        self.livePrint.text = "Final Results"
                    }
                }
                self.total = self.results["total_votes"] as! Float
                self.showResults()
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
    
    func showResults() {
        print("Creating results")
        DispatchQueue.main.async {
            var labelY = 160
            for candidate in self.candidates {
                print(candidate)
                let temp = (self.voteCounts[candidate] as! Int)
                let votes = String(temp)
                let percentage = ((self.voteCounts[candidate] as! Float)/self.total) * 100
                let resultLabel = UILabel(frame: CGRect(x: 20, y: labelY, width: 150, height: 60))
                let resultLabel2 = UILabel(frame: CGRect(x: 260, y: labelY, width: 30, height: 60))
                let resultLabel3 = UILabel(frame: CGRect(x: 315, y: labelY, width: 80, height: 60))
                labelY = labelY + 50
                
                resultLabel.text = candidate
                resultLabel.textColor = UIColor.black
                resultLabel2.text = votes
                resultLabel2.textColor = UIColor.black
                resultLabel3.text = String(format:"%.2f%%", percentage)
                resultLabel3.textColor = UIColor.black
                
                self.view.addSubview(resultLabel)
                self.view.addSubview(resultLabel2)
                self.view.addSubview(resultLabel3)
            }
        }
    }
    
    // if the poll is closed, say that poll is closed
    // otherwise, say live analytics and you need to figure out how to loop to continuously be able to check for updates in results
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VoteReadyViewController
        {
            let vc = segue.destination as? VoteReadyViewController
            vc!.electionName = electionName
            vc!.electionIDpassed = electionID
            vc!.token = token
            vc!.hostName = host
        }
    }
}

