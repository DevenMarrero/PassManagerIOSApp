//
//  Extensions.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-04.
//

import UIKit

//Hide Keyboard When Screen is Tapped
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//Strip WhiteSpace
extension String {
    
    //Removes Whitespace from beginnning/end of string
    func strip() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //Return true/false if strings has at least 1 char in other string
    func hasOne(string: String) -> Bool{
        for char in string{
            if self.contains(char) {
                return true
            }
        }
        return false
    }
    
    func stringToArray() -> [[String]]{
        let test = self.replacingOccurrences(of: "'", with: "\"").replacingOccurrences(of: "], [", with: "<>").replacingOccurrences(of: "[[", with: "").replacingOccurrences(of: "]]", with: "")
        let array = test.components(separatedBy: "<>")
        
        var final = [[String]]()
        for var item in array {
            item = item.replacingOccurrences(of: "\"", with: "")
            let temp = item.components(separatedBy: ", ")
            final.append(temp)
        }
        return final
    }
    
}
