//
//  ViewController.swift
//  Chatter
//
//  Created by Kevin Lee on 9/20/19.
//  Copyright © 2019 Kevin Lee. All rights reserved.
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

class ChattTableViewController: UITableViewController {
    
    var chatts = [Chatt]()
    func refreshChatts() {
        let requestURL = "http://134.209.218.243/getchatts/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                self.refreshControl?.endRefreshing()
                return
            }
            do {
                var newChatts = [Chatt]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let chattsReceived = json["chatts"] as? [[String]] ?? []
                for chattEntry in chattsReceived {
                    let chatt = Chatt(username: chattEntry[0], message: chattEntry[1], timestamp: chattEntry[2])
                    newChatts += [chatt]
                }
                self.chatts = newChatts
                DispatchQueue.main.async{
                    self.tableView.estimatedRowHeight = 140
                    self.tableView.rowHeight = UITableView.automaticDimension
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true) }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
            section: Int) -> Int {
            return chatts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ChattTableCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChattTableCell else {             fatalError("The dequeued cell is not an instance of ChattTableCell")
        }
        let chatt = chatts[indexPath.row]
        cell.usernameLabel.text = chatt.username
        cell.usernameLabel.sizeToFit()
        cell.messageLabel.text = chatt.message
        cell.messageLabel.sizeToFit()
        cell.timestampLabel.text = chatt.timestamp
        cell.timestampLabel.sizeToFit()
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.refreshControl?.addTarget(self, action:
            #selector(ChattTableViewController.handleRefresh(_:)), for:
            UIControl.Event.valueChanged)
        self.refreshChatts()
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshChatts() }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
}

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    @IBAction func submitClicked(_ sender: UIBarButtonItem) {
        let json: [String: Any] = ["username": self.usernameLabel.text ?? "NULL", "message": self.messageTextView.text ?? "I wrote a blank message, oops!"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url:
            URL(string: "http://134.209.218.243/addchatt/")!)
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
        }
        task.resume()
        
        dismiss(animated: true, completion: nil)
    }
}
