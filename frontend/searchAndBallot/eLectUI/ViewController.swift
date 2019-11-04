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
    
    let data = ["test0", "test1", "test2", "Test0", "Test1", "Test2", "tester", "testing", "test this", "t0", "t1", "t2", "t3"]
    
    var results = [String]()
    var searching = false
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

class CreateOptionViewController: UIViewController {
    
    
    @IBOutlet weak var optionName: UITextField!
    @IBOutlet weak var optionInfo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    @IBAction func addVotingOption(_ sender: UIBarButtonItem) {
        // Package information into JSON
        let json: [String: Any] = [ "optionName": self.optionName.text!, "optionInfo": self.optionInfo.text ?? "NULL"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url:
            URL(string: "http://134.209.218.243/addchatt/")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse,
                httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
        }
        task.resume()
        
        // goes back to preview view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelVotingOption(_ sender: UIBarButtonItem) {
        // goes back to preview view controller
        dismiss(animated: true, completion: nil)
    }
    
}

class ProposalViewController: UITableViewController {
    
    var votingOptions = [votingOption]()
    
    func refreshOptions() {
        // need to figure out how to send the voting option to the database, and get all of the voting options back
        let requestURL = "http://159.89.181.188/getchatts/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            do {
                var newOptions = [votingOption]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let optionsReceived = json["votingOptions"] as? [[String]] ?? []
                
                for optionEntry in optionsReceived {
                    let option = votingOption(optionName: optionEntry[0], optionInfo: optionEntry[1])
                    newOptions += [option]
                }
                self.votingOptions = newOptions
                self.tableView.estimatedRowHeight = 140
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
            catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView,  didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return votingOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "OptionTableCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OptionTableCell else {
                fatalError("The dequeued cell is not an instance of ChattTableCell")
        }
        let option = votingOptions[indexPath.row]
        cell.optionName.text = option.optionName
        cell.optionName.sizeToFit()
        cell.optionInfo.text = option.optionInfo
        cell.optionInfo.sizeToFit()
        return cell
    }
    
    /* override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.refreshControl?.addTarget(self, action: #selector(ProposalViewController.handleRefresh(_:)), for:
            UIControl.Event.valueChanged)
        
        NEED TO FIGURE OUT HOW TO REFRESH THE TABLE VIEW, becuase its not a table view controller
    } */
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshOptions()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
}
