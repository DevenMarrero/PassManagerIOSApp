//
//  AccountCell.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-13.
//

import UIKit


protocol AccountCellDelegate: AnyObject {
    func didTapButton(with account: Account)
}

class AccountCell: UITableViewCell {

    weak var delegate: AccountCellDelegate?
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    private var accountObj:Account = Account("", "", "", "", "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setAccount(account: Account) {
        self.accountObj = account
        accountLabel.text = accountObj.account
        favouriteButton.setImage(accountObj.favourite, for: .normal)
    }
    
    @IBAction func favouritePressed(_ sender: Any) {
        if favouriteButton.currentImage == UIImage(systemName: "star") {
            favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }else{
            favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        delegate?.didTapButton(with: self.accountObj)
    }
}
