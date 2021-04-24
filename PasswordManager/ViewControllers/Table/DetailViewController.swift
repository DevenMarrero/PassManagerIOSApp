//
//  DetailViewController.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-13.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var noteView: UITextView!
    var account: Account = Account("", "", "", "", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView(accountObj: account)
    }
    
    func setupView(accountObj: Account) {
        self.accountLabel.text = accountObj.account
        self.usernameLabel.text = accountObj.username
        self.passwordLabel.text = accountObj.password
        self.noteView.text = accountObj.note
    }

    @IBAction func editPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as? EditViewController
        vc?.accountObj = account
//        performSegue(withIdentifier: "goToEdit", sender: nil)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
