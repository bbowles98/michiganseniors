//
//  SignInSignUp.swift
//  CreateElection
//
//  Created by Kevin Lee on 11/8/19.
//  Copyright © 2019 Madelyn Rycenga. All rights reserved.
//

import Foundation
import UIKit


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
                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
}



class SignUpViewController: UIViewController {
    @IBOutlet weak var Signup_Email_Input: UITextField!
    @IBOutlet weak var Signup_Password_Input: UITextField!
    
    
    @IBAction func SignUpClicked(_ sender: UIButton) {
        let json: [String: Any] = ["username": self.Signup_Email_Input.text ?? "NULL",
                                   "password": self.Signup_Password_Input.text ?? "I wrote a blank message, oops!", "email": self.Signup_Email_Input.text ?? "NULL"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        
        var request = URLRequest(url:
            URL(string: "http://204.48.30.178/signup/")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //request.addValue("JWT " + whatever_token, forHTTPHeaderField: "Authorization")
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
                //let json_response = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                

                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
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
