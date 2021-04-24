//
//  EditViewController.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-17.
//

import UIKit

class EditViewController: UIViewController, UITextViewDelegate{
    
    let client = Conn.shared.client
    var accountObj: Account = Account("", "", "", "", "")
    let deleteAlert = UIAlertController(title: "Delete Password", message: "All data for this account will be lost.", preferredStyle: UIAlertController.Style.alert)
    
    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var noteView: UITextView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        setupView(accountObj: accountObj)
        doneButton.isEnabled = true
        noteView.delegate = self
        if noteView.text == "" {
            noteView.text = "Note (Optional)"
            noteView.textColor = UIColor.lightGray
        }
        
        [accountField, usernameField, passwordField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        // DeleteAlert
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            //Delete
            self.client.send(msg: "remove_pass: \(self.accountObj.account)")
            let _ = self.client.getReceive()
            //Go back to browseViewController
            self.navigationController?.popToRootViewController(animated: true)
        }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              //Cancel
        }))
        
    }
    
    //Load account items
    func setupView(accountObj: Account) {
        self.accountField.text = accountObj.account
        self.usernameField.text = accountObj.username
        self.passwordField.text = accountObj.password
        self.noteView.text = accountObj.note
    }
    
    //Checks if all fields filled
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
    
    //Delete Password
    @IBAction func deletePressed(_ sender: Any) {
        //Confirm
        present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        let account = accountField.text?.strip()
        let username = usernameField.text?.strip()
        let password = passwordField.text?.strip()
        var note = noteView.text?.strip()
        if noteView.textColor == UIColor.lightGray {
            note = nil
        }
        
        client.send(msg: "remove_pass: \(accountObj.account)")
        print(client.getReceive())
        var favourite = 0
        if accountObj.favourite == UIImage(systemName: "star.fill") {
            favourite = 1
        }
        client.send(msg: "create_pass: \(account!)<>\(username!)<>\(password!)<>\(note ?? "")<>\(favourite)")
        let received = client.getReceive()
        if received.contains("Error:") {
            print(received)
        }
        else {
            //Go back to browseViewController
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //Remove Placeholder from noteView
    func textViewDidBeginEditing(_ noteView: UITextView) {
        if noteView.textColor == UIColor.lightGray {
            noteView.text = nil
            noteView.textColor = UIColor.label
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
