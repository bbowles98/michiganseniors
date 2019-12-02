//
//  ElectManageViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/25/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit
class ElectManageViewController: UIViewController {
    
    var data = elections
    var results: [Dictionary<String, Any>] = []
    var searching = false
    var selectedElect = 0
    var electionID = ""
    var token:String = ""
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        let getURL = "http://204.48.30.178/elections/"
        
        
        // Get the data to load the ballot
        var request = URLRequest(url:
            URL(string: getURL)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
         
         print("election creation token")
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
                //print(json.debugDescription)
                //print(json)
                elections = json["election"] as! [Dictionary<String, Any>]
                //print(elections)
            }
           catch let error as NSError {
            print(error)
           }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedElect = indexPath.row
        self.performSegue(withIdentifier: "ToDelete", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DeleteElectViewController
        {
            let vc = segue.destination as? DeleteElectViewController
            
            vc!.token = token
           if (searching) {
                vc!.electionName = results[selectedElect]["name"] as! String
                vc!.hostName = results[selectedElect]["creator"] as! String
                vc!.electionIDpassed = String(results[selectedElect]["election_id"] as! Int)
            }
            else {
                let election = elections[selectedElect]
                vc!.electionName = election["name"] as! String
                vc!.hostName = election["creator"] as! String
                vc!.electionIDpassed = String(election["election_id"] as! Int)
            }
        }
    }
}

extension ElectManageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return results.count
        } else {
            return elections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("kevins test")
        let cell = UITableViewCell()
        if searching {
            cell.textLabel!.text = (results[indexPath.row]["name"] as! String)
        } else {
            cell.textLabel!.text = (elections[indexPath.row]["name"] as! String)
        }
        return cell
    }
}

extension ElectManageViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        results = elections.filter({(($0["name"] as! String).lowercased() ).prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tblView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tblView.reloadData()
    }
    
}
