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
//*******************************************************SIGN IN***************************************************//
//*****************************************************************************************************************//
class SignInViewController: UIViewController {
    @IBOutlet weak var Email_Input: UITextField!
    @IBOutlet weak var Password_input: UITextField!
    
    @IBAction func SignInClicked(_ sender: UIButton) {
        let json: [String: Any] = ["username": self.Email_Input.text ?? "NULL",
                                   "password": self.Password_input.text ?? "I wrote a blank message, oops!"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url:
            URL(string: "http://204.48.30.178/login/")!)
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
            if let httpStatus = response as? HTTPURLResponse,
                httpStatus.statusCode != 200 {
                print(response.debugDescription)
                print("HTTP STATUS yayay: \(httpStatus.statusCode)")
            
                //show alert
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Login Error", message:
                        "Unrecognized email and/or password", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                
                return
                }
            }
            else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let s = String(describing: json["token"])
                    token_response = s
                    
                    let temp1 = token_response.split(separator: "(")[1]
                    token_response = String(temp1.split(separator: ")")[0])
                    
                    print("Signin Token response: " + token_response)
                }
                catch let error as NSError {
                               print(error)
                           }
                self.navigateToMainInterface()
            }
            
        }
        //run the previous copule lines of code in a seperate thread
        task.resume()
    
        dismiss(animated: true, completion: nil)
        /*
        ********************CODE FOR PASSING DATA IF WE WANT TO USE SEGUE INSTEAD OF GLOBALS***********************
        self.token_to_pass = token_response
        performSegue(withIdentifier: "Insert Seguename Here", sender: self)
        
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            var vc = segue.destination as! CastVoteViewController
            vc.token = self.token_to_pass
        }
        */
    }
    
    private func navigateToMainInterface() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
       
        DispatchQueue.main.async{
            guard let mainNavagationVC = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController
                
                else {
                    return
                }
 
            self.present(mainNavagationVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
}
//***********************************************CREATE ELECTION***************************************************//
//*****************************************************************************************************************//

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
    var token:String = token_response
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
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:00"
        startString = dateFormatter.string(from: selectedStart.date)
        endString = dateFormatter.string(from: selectedEnd.date)
        
        // Package information into JSON
        let json: [String: Any] = [ "name": self.ElectionName.text ?? "NULL",
                                    "elec_is_public": isPublic,
                                    "start_date": startString,
                                    "end_date": endString
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url:
            URL(string: "http://204.48.30.178/election/")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //parse out token response
        //let temp1 = token.split(separator: "(")[1]
       // let token_response = temp1.split(separator: ")")[0]
        
        
        print("election creation token")
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
   
            let json = try? (JSONSerialization.jsonObject(with: data!) as! [String: Any])
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


//************************************************* ELECTION VIEW **************************************************//
//*****************************************************************************************************************//
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
            print(cell.optionName.text!)
            
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
        
        //_ = token_response
        //let temp2 = token_response.split(separator: "(")[1]
        //let token_response = temp2.split(separator: ")")[0]
        
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
        performSegue(withIdentifier: "ToPreview", sender: (Any).self)
        //dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PreviewElectionViewController
        {
            let vc = segue.destination as? PreviewElectionViewController
            vc!.token = token_response
        }
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

//************************************************  CREATE OPTIONS ************************************************//
//*****************************************************************************************************************//
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

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    var token:String = token_response
    
    @IBAction func SearchSegue(_ sender: Any) {
        self.performSegue(withIdentifier: "ToSearch", sender: (Any).self)
    }
    @IBAction func CreateSegue(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ToCreate", sender: (Any).self)
    }
    
    @IBAction func toCreatedElects(_ sender: Any) {
        self.performSegue(withIdentifier: "ToMyElects", sender: (Any).self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ToSearch"
        {
            print("going in to search segue!!: " + token)
            let navVC = segue.destination as? UINavigationController
            let vc = navVC?.viewControllers.first as? SearchViewController
            vc!.token = token
        }
        else if segue.destination is ElectManageViewController {
            let vc = segue.destination as? ElectManageViewController
            vc!.token = token
        }
    }
}

