//
//  DeleteElectViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/25/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit

class DeleteElectViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        electNameLabel.text = self.electionName
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    var token:String = ""
    var electionName:String = ""
    var hostName:String = ""
    var electionIDpassed:String = ""
    @IBOutlet weak var electNameLabel: UILabel!
    @IBAction func onSendResults(_ sender: Any){
        print("THIS IS WHERE YOURE SENDING DELETE REQUEST")
    let getURL = "http://204.48.30.178/notify/"
           let json: [String: Any] = ["election_id": self.electionIDpassed ?? "NULL",
                                      ]
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
                   }
                  catch let error as NSError {
                   print(error)
                  }
               }
               task.resume()
        
        performSegue(withIdentifier: "JustForwarded", sender: (Any).self)
    }

    
    @IBAction func onDelete(_ sender: Any) {
        let json: [String: Any] = ["election_id": self.electionIDpassed ?? "NULL",
                                   ]
        print(json)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let getURL = "http://204.48.30.178/delete/"
        
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
                   }
                  catch let error as NSError {
                   print(error)
                  }
               }
               task.resume()
        
        performSegue(withIdentifier: "JustDeleted", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is MainViewController
        {
            let vc = segue.destination as? MainViewController
            vc!.token = token
        }
    }
    
}
