//
//  ViewController.swift
//  Create_Election
//
//  Created by Madelyn Rycenga on 11/2/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//
import UIKit
var propChoices = [votingOption]()
var help = [String]()
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
    var token:String = ""
    var electID = ""
    @IBOutlet weak var selectedStart: UIDatePicker!
    @IBOutlet weak var selectedEnd: UIDatePicker!
    
    @IBAction func createClicked(_ sender: UIBarButtonItem) {
        
        print("give me a gd number: ")
        print(electID)
        
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
        print("POST", jsonData)
        var request = URLRequest(url:
            URL(string: "http://204.48.30.178/election/")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print("election creation token")
        self.token = token_response
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
            print("HERE", json!["election_id"])
            election_id =  (json!["election_id"])!
            print("please print a number: ")
            print(type(of: election_id))
            var temp = election_id as! Int
            self.electID = String(temp)
            print("Printing election id here: ", self.electID)
            
            // Create election object
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "ToAuthenticate", sender: self)

            }
        }
        
        task.resume()
        
//        print("Printing the election ids: ")
//        print(self.electID)
//        print(election_id)
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAuthenticate" {
            print("Going to authication view: " + token_response)
            let navVC = segue.destination as? UINavigationController
            let vc = navVC?.viewControllers.first as? AuthenticationSetUpViewController
            //if token_response != nil {
                vc!.token = token_response
            //}
            //else {
                //vc!.token = ""
            //}
            print("printing electID before segue")
            print(self.electID)
            vc!.electID = self.electID
        }
        
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
    @IBOutlet weak var newOption: UITextField!
    @IBOutlet var tblView: UITableView!
    
    @IBAction func addItem(_ sender: Any) {
        print("it got here")
        //if newOption.text != nil {
            
        /* let option = votingOption(optionName: newOption.text!, optionInfo: "NULL")
        propChoices.append(option)
        newOption.text = ""
        print("did it append")
        for choice in propChoices {
            print("printing propChoices")
            print(choice.optionName)
            print("what the fuck")
        } */
        
        help.append(newOption.text!)
        newOption.text = ""
        print("it added and here is the new array: ")
        for item in help {
            print(item)
        }
        
        tblView.reloadData()
        
        //}
    }
    
    
    //func refreshOptions() {

    //}
    
    //override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    //}
    
    /* override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 } */
    
    //override func viewDidAppear(_ animated: Bool) {
    //    print("is this happening?")
    //    tblView.reloadData()
    //}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
            section: Int) -> Int {
        print("printing propchoices size")
        print(propChoices.count)
        //return propChoices.count
        return help.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cellIdentifier = "OptionTableCell"
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OptionTableCell else {
        //    fatalError("The dequeued cell is not an instance of OptionTableCell")
        //}
        
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "OptionTableCell")
        /* let option = propChoices[indexPath.row]
        
        print("Printing optionName")
        print(option.optionName)
        cell.textLabel?.text = option.optionName */
        
        cell.textLabel?.text = help[indexPath.row]
        //cell.optionName.text = String(option.optionName)
        //print("Should print yes: ")
        //print(cell.optionName.text!)
        
        //cell.optionName.sizeToFit()
        return cell
    }
    
    
    
    
    override func viewDidLoad() {
        print("what is happening")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.refreshControl?.addTarget(self, action:
        //    #selector(ElectionViewController.handleRefresh(_:)), for:
        //    UIControl.Event.valueChanged)
       //self.refreshOptions()
    }
    var answers = [String]()
    var electionQuestion = ""
    var token:String = ""
    var electID:String = ""
    
    @IBAction func previewBallot(_ sender: Any) {
        
        // need to add the proposal name and make the JSON
      let propName = self.propName.text!
      let election = Proposal(question: propName, choices: propChoices)
      self.token = token_response
      //self.electID = election_id
      
      
      for choice in propChoices {
          self.answers.append(choice.optionName)
      }
      electionQuestion = election.question
      print(self.answers)
      print(self.electionQuestion)
        print("printing electID to test: ")
        print(self.electID)
  
      // API REQUEST
      let json: [String: Any] = [
          "election_id": electID,
         "ballot_items": [
              [
                  "question": election.question,
                  "choices" : self.answers
              ]
          ]
      ]
      
      print("questions: " + election.question)
      
      let jsonData = try? JSONSerialization.data(withJSONObject: json)
      var request = URLRequest(url: URL(string: "http://204.48.30.178/ballot/")!)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      
      request.addValue("JWT " + token_response, forHTTPHeaderField: "Authorization")
      print("ballot token:")
      print(token_response)
      request.httpMethod = "POST"
      request.httpBody = jsonData
      print("electID 338: ")
        print(electID)
      print("jsonData 338: ")
      
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
          
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PreviewElectionViewController
        {
            let vc = segue.destination as? PreviewElectionViewController
            vc!.token = token_response
            vc!.electionQuestion = self.electionQuestion
            vc!.choices = self.answers
            vc!.election_id = self.electID
        }
    }
        
    
    @IBAction func cancelElection(_ sender: UIBarButtonItem) {
        
        // don't want to actually add any questions to election
        dismiss(animated: true, completion: nil)
    }
    
    //@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    //    self.refreshOptions()
    //}
    
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
        
        print("printing added choice here:")
        print(option.optionName)
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

