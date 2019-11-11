//
//  ViewController.swift
//  Create_Election
//
//  Created by Madelyn Rycenga on 11/2/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//
import UIKit
var propChoices = [votingOption]()
var token_response = ""
var election_id: Any = -1
var electPass = ""
var elections: [Dictionary<String, Any>] = []


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


class LandingPageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
}

class CreateElectViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    // Data to be collected from page

    @IBOutlet weak var ElectionName: UITextField!
    @IBOutlet weak var viewSelector: UISegmentedControl!

    @IBOutlet weak var selectedStart: UIDatePicker!
    @IBOutlet weak var selectedEnd: UIDatePicker!
    
    @IBAction func createClicked(_ sender: UIBarButtonItem) {
        // the election has been set up, proceed to ballot creation
        print("sanitycheck here")
        // Determine who can view the election
        var isPublic = "false"
        if (viewSelector.isEnabledForSegment(at: 0)) {
            isPublic = "true"
        }
        
        // Check fields are valid
        var startString: String
        var endString: String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        startString = dateFormatter.string(from: selectedStart.date)
        endString = dateFormatter.string(from: selectedStart.date)
        
        
        // Package information into JSON
        let json: [String: Any] = [ "name": self.ElectionName.text ?? "NULL",
                                    "elec_is_public": isPublic,
                                    "startDate": startString,
                                    "endDate": endString
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url:
            URL(string: "http://204.48.30.178/election/")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let s = String(describing: token_response)
        var token = s
        let temp1 = token.split(separator: "(")[1]
        let token_response = temp1.split(separator: ")")[0]
        
        request.addValue("JWT " + token_response, forHTTPHeaderField: "Authorization")
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
   
            let json = try? JSONSerialization.jsonObject(with: data!) as! [String: Any]
            election_id =  (json!["election_id"])!
            print(election_id)
     
        }
        
        task.resume()
        
        // Create election object
        performSegue(withIdentifier: "segueToVotingOptions", sender: self)
        
    }
}

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
}

// when you add the proposal, then you add all of the voting objects
class ElectionViewController: UITableViewController {
    
    @IBOutlet weak var propName: UITextView!
    
    func refreshOptions() {

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
            print("Should print yes: ")
            print(cell.optionName.text)
            
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
        let json: [String: Any] = [
            "election_id": election_id,
           "ballot_items": [
                [
                    "question": election.question,
                    "choices" : answers
                ]
            ]
        ]
        
        print("questions: " + election.question)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: URL(string: "http://204.48.30.178/ballot/")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let temp1 = token_response
        let temp2 = token_response.split(separator: "(")[1]
        let token_response = temp2.split(separator: ")")[0]
        
        request.addValue("JWT " + token_response, forHTTPHeaderField: "Authorization")
        print("ballot token:")
        print(token_response)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        print("jsonData: ")
        
        if let string = String(bytes: jsonData!, encoding: .utf8) {
            print(string)
        }
        
  
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
        
        print("printing choices here:")
        print(propChoices[0].optionName)
        // goes back to preview view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelVotingOption(_ sender: UIBarButtonItem) {
        // goes back to preview view controller
        dismiss(animated: true, completion: nil)
    }
    
}



class SearchViewController: UIViewController {

//@IBAction func testGetReq(_ sender: UIButton) {
    
    var data = elections
    var results: [Dictionary<String, Any>] = []
    var searching = false
    var selectedElect = 0
    var electionID = ""
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
        //performSegue(withIdentifier: "segue", sender: self)
        electPass = results[selectedElect]["passcode"] as! String
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("here")
        if segue.destination is VoteReadyController
        {
            let vc = segue.destination as? VoteReadyController
            vc!.electionID = electionID
            if (searching) {
                vc!.electionName = results[selectedElect]["name"] as! String
                vc!.hostName = results[selectedElect]["creator"] as! String
                vc!.electionID = results[selectedElect]["election_id"] as! String
            }
            else {
                let election = elections[selectedElect]
                vc!.electionName = election["name"] as! String
                vc!.hostName = election["creator"] as! String
                vc!.electionID = election["election_id"] as! String
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

