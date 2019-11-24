//
//  SearchViewController.swift
//  CreateElection
//
//  Created by Madelyn Rycenga on 11/24/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit
class SearchViewController: UIViewController {
    
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
        let getURL = "http://204.48.30.178/search?name="
        
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
                elections = json["election"] as! [Dictionary<String, Any>]
                print(elections)
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
        self.performSegue(withIdentifier: "ToReady", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VoteReadyViewController
        {
            let vc = segue.destination as? VoteReadyViewController
            
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return results.count
        } else {
            return elections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if searching {
            cell.textLabel!.text = (results[indexPath.row]["name"] as! String)
        } else {
            cell.textLabel!.text = (elections[indexPath.row]["name"] as! String)
        }
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
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
