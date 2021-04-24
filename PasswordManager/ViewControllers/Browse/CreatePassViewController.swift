//
//  CreatePassViewController.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-11.
//

import UIKit

class CreatePassViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var noteView: UITextView!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var favourite: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide Keyboard When screen is tapped
        self.hideKeyboardWhenTappedAround()
        
        ErrorLabel.isHidden = true
        ErrorLabel.textColor = .systemRed
        doneButton.isEnabled = false
        
        //Add border to noteView
        self.noteView.layer.borderColor = UIColor.darkGray.cgColor
        self.noteView.layer.borderWidth = 1
        
        //PlaceHolder for noteView
        noteView.delegate = self
        noteView.text = "Note (Optional)"
        noteView.textColor = UIColor.lightGray
        
        //Give text fields editingChanged func
        [accountField, usernameField, passwordField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
            
        }
    //Enable done button if fields filled
    @objc func editingChanged(sender: UITextField) {

        sender.text = sender.text?.strip()

        guard
          let account = accountField.text, !account.isEmpty,
          let username = usernameField.text, !username.isEmpty,
          let password = passwordField.text, !password.isEmpty
          else{
          self.doneButton.isEnabled = false
          return
        }
        // enable okButton if all conditions are met
        doneButton.isEnabled = true
       }
    
    //Send data to server
    @IBAction func donePressed(_ sender: Any) {
        let client = Conn.shared.client
        
        let account = accountField.text?.strip()
        let username = usernameField.text?.strip()
        let password = passwordField.text?.strip()
        var note = noteView.text?.strip()
        if noteView.textColor == UIColor.lightGray {
            note = nil
        }
        
        client.send(msg: "create_pass: \(account!)<>\(username!)<>\(password!)<>\(note ?? "")<>\(favourite)")
        let received = client.getReceive()
        if received.contains("Error:") {
            ErrorLabel.text = received
            ErrorLabel.isHidden = false
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Close View
    @IBAction func cancelPressed(_ sender: Any) {
        //Close View
        self.dismiss(animated: true, completion: nil)
    }
    
    //Toggle and set favourite
    @IBAction func favouritePressed(_ sender: Any) {
        let button = sender as? UIButton
        if favourite == 0{
            favourite = 1
            button?.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }else{
            favourite = 0
            button?.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    //Remove Placeholder from noteView
    func textViewDidBeginEditing(_ noteView: UITextView) {
        if noteView.textColor == UIColor.lightGray {
            noteView.text = nil
            noteView.textColor = UIColor.systemTeal
        }
    }
    //Add placeholder to noteView
    func textViewDidEndEditing(_ noteView: UITextView) {
        if noteView.text.isEmpty {
            noteView.text = "Note (Optional)"
            noteView.textColor = UIColor.lightGray
        }
    }
    
}
