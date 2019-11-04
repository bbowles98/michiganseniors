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

class SignInViewController: UIViewController {
    
    @IBOutlet weak var FullName_Input: UITextField!
    @IBOutlet weak var Email_Input: UITextField!
    @IBOutlet weak var Password_input: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be created
    }
    
    @IBAction func SignInClicked(_ sender: UIButton) {
        //grab all relevant information from sign in form
        let json: [String: Any] = ["fullname": self.FullName_Input.text ?? "Full Name is a required",
                                    "email": self.Email_Input.text ?? "Email is a required field",
                                    "password": self.Password_input.text ?? "Password is a required field"]
        
        //package those relevant information into a json object
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        
        var request = URLRequest(url:
            URL(string: "204.48.30.178/users/")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        //async error handling
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
        //run the previous copule lines of code in a seperate thread
        task.resume()
        
        dismiss(animated: true, completion: nil)
    }
}
