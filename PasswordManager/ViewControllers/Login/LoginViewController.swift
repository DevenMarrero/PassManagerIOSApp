//
//  LoginViewController.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-04.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var UsernameField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var ServerIPField: UITextField!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide Keyboard When screen is tapped
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
        ErrorLabel.isHidden = true
        ErrorLabel.textColor = .systemRed
        
        let savedIP = UserDefaults.standard.string(forKey: "savedIP")
        if savedIP != "" {
            ServerIPField.text = savedIP
        }
    }
    //Hide Nav Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func ContinuePressed(_ sender: Any) {
        let Username = UsernameField.text?.strip()
        
        let Password = PasswordField.text?.strip()
        
        let ServerIP = ServerIPField.text?.strip()

        if Username == "" || Password == "" ||
            ServerIP == ""{
            ErrorLabel.text = "Error: All Text Fields must be Filled"
            ErrorLabel.isHidden = false
            
        }
        else if !(ServerIP!.contains(":")) {
            ErrorLabel.text = "Error: Server Field Must be in Form (ServerIP:Port)"
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
            //Everything Good
            else{
                ErrorLabel.isHidden = true
                //Set IP/Port then start client
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
                
                //save IP
                UserDefaults.standard.set(ServerIP, forKey: "savedIP")
                //Call Login
                client.send(msg: "login: \(Username!)<>\(Password!)")
                let received = client.getReceive()
                if received.contains("Error:") {
                    ErrorLabel.text = received
                    ErrorLabel.isHidden = false
                    client.stop()
                }
                else {
                    //Connected to Server
                    performSegue(withIdentifier: "goToHome", sender: nil)
                }
                
            }
        }
        
    } // End of button
    
}
