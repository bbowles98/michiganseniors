//
//  ViewController.swift
//  eLect2
//
//  Created by Grace Economou on 11/2/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
}

class SearchViewController: UIViewController {

@IBAction func testGetReq(_ sender: UIButton) {
    
    let requestURL = "http://204.48.30.178/search?name=Test"
    var request = URLRequest(url: URL(string: requestURL)!)
    request.httpMethod = "GET"
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let _ = data, error == nil else {
            print("NETWORKING ERROR")
            DispatchQueue.main.async {
                //self.refreshControl?.endRefreshing()
            }
            
            return
        }
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("HTTP STATUS: \(httpStatus.statusCode)")
            //self.refreshControl?.endRefreshing()
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
            //let chattsReceived = json["chatts"] as? [[String]] ?? []
            print(json.debugDescription)
            print(json)

        }
        catch let error as NSError {
            print(error)
        }
    }
    task.resume();
}

    

    let data = ["test0", "test1", "test2", "Test0", "Test1", "Test2", "tester", "testing", "test this", "t0", "t1", "t2", "t3"]
    
    var results = [String]()
    var searching = false
    var selectedElect = 0
    var electionID = ""
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedElect = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VoteReadyController
        {
            let vc = segue.destination as? VoteReadyController
            vc!.electionID = electionID
            if (searching) {
                vc!.electionName = results[selectedElect]
                vc!.hostName = results[selectedElect]
            }
            else {
                vc!.electionName = data[selectedElect]
                vc!.hostName = data[selectedElect]
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return results.count
        } else {
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if searching {
            cell.textLabel?.text = results[indexPath.row]
        } else {
            cell.textLabel?.text = data[indexPath.row]
        }
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        results = data.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tblView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tblView.reloadData()
    }
    
}
