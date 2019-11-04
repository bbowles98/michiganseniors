//
//  ViewController.swift
//  eLect2
//
//  Created by Grace Economou on 11/2/19.
//  Copyright © 2019 Grace Economou. All rights reserved.
//

import UIKit
var propChoices = [votingOption]()

// NEED TO CREATE GLOBAL Proposal OBJECT

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
    
    // need to do API call to get all of the possible elections
    
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




// when you add the proposal, then you add all of the voting objects
class ElectionViewController: UITableViewController {
    
    @IBOutlet weak var propName: UITextView!
    
    //var choices = [votingOption]()
    //var propChoices = [String]()
    //var propC:String = ""
    
    //propChoices.append(propC)
    
    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CreateOptionViewController {
            
            let vc = segue.destination as? CreateOptionViewController
            vc!.propC = propC
        
        }
    } */
    
    //var newProp = Proposal(proposalName: self.proposalName.text!, proposalOptions: propC)
    
    func refreshOptions() {
/*
        where get requests go
 */
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true) }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
            section: Int) -> Int {
            return propChoices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "OptionTableCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OptionTableCell else {
            fatalError("The dequeued cell is not an instance of OptionTableCell")
        }
        let option = propChoices[indexPath.row]
        cell.optionName.text = option.optionName
        cell.optionName.sizeToFit()
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.refreshControl?.addTarget(self, action:
            #selector(ElectionViewController.handleRefresh(_:)), for:
            UIControl.Event.valueChanged)
        self.refreshOptions()
    }
    
    @IBAction func makeElection(_ sender: UIBarButtonItem) {
        
        // need to add the proposal name and make the JSON
        let propName = self.propName.text!
        let election = Proposal(question: propName, choices: propChoices)
        
        var answers = [String]()
        for choice in propChoices {
            answers.append(choice.optionName)
        }
        
        // API REQUEST
        let json: [String: Any] = ["election_id": <GETELECTIONID>, "ballot_items": [{"question": election.question, "choices" : answers }]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: URL(string: "http://204.48.30.178/ballot/")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        print(request.debugDescription)
        
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
                let s = String(describing: json["token"])
                token_response = s
                let temp1 = token_response.split(separator: "(")[1]
                let token_response = temp1.split(separator: ")")[0]
            }
            catch let error as NSError {
                print(error)
            }
        }
        //run the previous copule lines of code in a seperate thread
        task.resume()
        
        dismiss(animated: true, completion: nil)
    }
        
    
    @IBAction func cancelElection(_ sender: UIBarButtonItem) {
        
        // don't want to actually add any questions to election
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshOptions() }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
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
        
        let option = votingOption(optionName: self.optionName.text!, optionInfo: self.optionInfo.text ?? "NULL")
        
        propChoices.append(option)
        
        // goes back to preview view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelVotingOption(_ sender: UIBarButtonItem) {
        // goes back to preview view controller
        dismiss(animated: true, completion: nil)
    }
    
}





