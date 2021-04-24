//
//  AccountClass.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-13.
//

import Foundation
import UIKit

class Account {
    var account:String
    var username:String
    var password:String
    var note:String
    var favourite:UIImage
    
    init(_ account: String, _ username: String, _ password: String, _ note: String, _ favourite: String){
        self.account = account
        self.username = username
        self.password = password
        self.note = note.replacingOccurrences(of: "\\n", with: "\n")
        if Int(favourite) == 1 {
            self.favourite = UIImage(systemName: "star.fill")!
        }else {
            self.favourite = UIImage(systemName: "star")!
        }
    }
}
