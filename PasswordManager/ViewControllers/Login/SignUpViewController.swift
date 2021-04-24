//
//  SignUpViewController.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-04.
//

import UIKit

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var UsernameField: UITextField!
    
    
    @IBOutlet weak var FirstNameField: UITextField!
    
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var ConfirmPasswordField: UITextField!
    
    @IBOutlet weak var ServerIPField: UITextField!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ErrorLabel.isHidden = true
        self.hideKeyboardWhenTappedAround()
        
        //get savedIP if available
        let savedIP = UserDefaults.standard.string(forKey: "savedIP")
        if savedIP != "" {
            ServerIPField.text = savedIP
        }
    }
    
    
    @IBAction func ContinuePressed(_ sender: Any) {
        let Username = UsernameField.text?.strip()
        let FirstName = FirstNameField.text?.strip()
        let Password = PasswordField.text?.strip()
        let ConfirmPassword = ConfirmPasswordField.text?.strip()
        let ServerIP = ServerIPField.text?.strip()
        
        if Username == "" || FirstName == "" ||
            Password == "" || ServerIP == "" || ConfirmPassword == ""{
            ErrorLabel.text = "Error: All Text Fields must be Filled"
            ErrorLabel.isHidden = false
        }
        else if Password != ConfirmPassword {
            ErrorLabel.text = "Error: Passwords do not Match"
            ErrorLabel.isHidden = false
        }
        else if Password!.count < 8 || !Password!.hasOne(string: "!@#$%&*?"){
            ErrorLabel.text = "Error: Password must be > 8 Characters and Contain a Symbol (!@#$%&*?)"
            ErrorLabel.isHidden = false
        }
        
        else if !(ServerIP!.contains(":")) {
            //Server Cannot be Split
            ErrorLabel.text = "Error: Server Field Must be in Form (IP:Port)"
            ErrorLabel.isHidden = false
        }
        else{
            // All Fields Filled
            let serverArray = ServerIP?.components(separatedBy: ":")
            let IP = (serverArray?.first)!
            let Port = UInt16((serverArray?.last)!) ?? 0
            
            if Port == 0 {
                ErrorLabel.text = "Error: Port Must be an Integer"
                ErrorLabel.isHidden = false
            }
            else{
                //Everything Good
                ErrorLabel.isHidden = true
                print("IP: \(IP) Port: \(Port)")
                gHost = IP
                gPort = Port
                Conn.shared.reset()
                let client = Conn.shared.client
                client.start()
                //Cancel if client could not connect
                if !client.isReady() {
                    ErrorLabel.text = "Error: Could not Connect to Server"
                    ErrorLabel.isHidden = false
                    client.stop()
                    return
                }
                //Connected to Server
                //save IP
                UserDefaults.standard.set(ServerIP, forKey: "savedIP")
                //call create user
                client.send(msg: "create_user: \(Username!)<>\(FirstName!)<>\(Password!)")
                var recieved = client.getReceive()
                if recieved.contains("Error:") {
                    ErrorLabel.text = recieved
                    ErrorLabel.isHidden = false
                }
                else {
                    //login to created user
                    client.send(msg: "login: \(Username!)<>\(Password!)")
                    recieved = client.getReceive()
                    if recieved.contains("Error:") {
                        ErrorLabel.text = recieved
                        ErrorLabel.isHidden = false
                    }
                    else {
                        //Connected to Server
                        performSegue(withIdentifier: "goToHome", sender: nil)
                    }
                }
            }
        }
        
    } // End of button
}
