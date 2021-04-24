//
//  BrowseViewController.swift
//  PasswordManager
//
//  Created by Deven Marrero on 2020-12-10.
//

import UIKit

class BrowseViewController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var accounts: [Account] = []
    
    var filteredAccounts: [Account] = []
    var shouldShowSearchResults = false
    
    var refresher: UIRefreshControl!
    var lastSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.hideKeyboardWhenTappedAround()
        //Setup searchController
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Passwords"
        searchController.searchBar.showsCancelButton = false
        searchController.obscuresBackgroundDuringPresentation = true
        //Setup table
        tableView.delegate = self
        tableView.dataSource = self
        //Setup Pull to refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(BrowseViewController.reload), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
        //Update Table
        accounts = create_array()
        tableView.reloadData()
        
    }
    
    
    func create_array() -> [Account] {
        var tempPasswords: [Account] = []
        
        let client = Conn.shared.client
        client.send(msg: "search_pass: <>0")
        let received = client.getReceive()
        let list = received.stringToArray()
        if list == [["[]"]] { //If no passwords exist
            return tempPasswords
        }
        
        
        for account in list {
            tempPasswords.append(Account(account[0], account[1], account[2], account[3], account[4]))
        }
        return tempPasswords
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredAccounts = accounts.filter({ (account: Account) -> Bool in
            return account.account.lowercased().contains(searchText.lowercased())
        })
        if searchText != "" {
            shouldShowSearchResults = true
            self.tableView.reloadData()
        }
        else {
            shouldShowSearchResults = false
            self.tableView.reloadData()
        }
        lastSearch = searchText
    }
    
    //Closing Searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.endEditing(false)
        searchController.isActive = false
        searchController.searchBar.text = lastSearch
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchController.searchBar.endEditing(false)
        searchController.isActive = false
        searchController.searchBar.text = lastSearch
    }

}


extension BrowseViewController: UITableViewDataSource, UITableViewDelegate {
    
    //set length of table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredAccounts.count
        }
        else{
            return accounts.count
        }
    }
    //Set table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
        
        var account: Account
        if shouldShowSearchResults {
            account = filteredAccounts[indexPath.row]
        }
        else{
            account = accounts[indexPath.row]
        }
        cell.setAccount(account: account)
        cell.delegate = self
        return cell
    }
    
    //Transition to DetailViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        if shouldShowSearchResults {
            vc?.account = filteredAccounts[indexPath.row]
        }
        else {
            vc?.account = accounts[indexPath.row]
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    //Refresh Table Data
    @objc func reload() {
        accounts = create_array()
        refresher.endRefreshing()
        tableView.reloadData()
    }
}

//For favourite Buttons
extension BrowseViewController: AccountCellDelegate {
    func didTapButton(with account: Account) {
        let client = Conn.shared.client
        client.send(msg: "toggle_favourite: \(account.account)")
        let received = client.getReceive()
        print(received)
    }
}
