//
//  FindFriendsViewController.swift
//  DataDiet
//
//  Created by Eric Zamora on 11/25/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import Hero

class FindFriendsViewController: UIViewController {
    let VT = ViewTransitioner()

    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    var initial_users: [User] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredSearches: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // initializes table and users from Firebase
        tableView.delegate = self
        tableView.dataSource = self
        createArray()
        
        // initializing search bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Friends"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .minimal;
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        tableView.reloadData()
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    func filterContentForSearchText(_ searchText: String, category: User? = nil){
        filteredSearches = users.filter{ (user: User) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased()) || user.fullname.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    func retrieveProfilePic(_ accountInfo: QueryDocumentSnapshot) -> UIImage? {
        let photoURLString = (accountInfo["profilePicURL"] as! String)
        let photoURL = URL(string: photoURLString)
        let data = try? Data(contentsOf: photoURL!)
        if let imageData = data {
            let image = UIImage(data: imageData)
            return image
        }
        return nil
    }
    
    func createArray() {
        
        let currentUID: String! = Auth.auth().currentUser?.uid
        let collectionRef = Firestore.firestore().collection("users")
        
        collectionRef.getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else if (snapshot?.isEmpty)!{
                    print("No users here")
                } else {
                    // if documents exist push to array
                    for document in (snapshot?.documents)!{
                        if currentUID != document.documentID {
                            let username = document.data()["username"] as! String
                            let firstName = document.data()["first_name"] as! String
                            let lastName = document.data()["last_name"] as! String
                            let UID = document.documentID
                            self.users.append(User(image:self.retrieveProfilePic(document)!, username: "@\(username)", fullname: "\(firstName) \(lastName)", UID: UID))
                            }
                        }
                    }
                self.tableView.reloadData()
                }
    }

    @IBAction func OnBackButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsView") as! SettingsViewController
        self.present(controller, animated: true, completion: nil)
    }
}

extension FindFriendsViewController: FriendCellDelegate {
    func didTapAdd(UID: String) {
        let currentUID: String! = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        // check if user exist in friends list if it does then don't send friend request
    db.collection("users").document(UID).collection("Friends").document("Pending").setData([currentUID : true], merge: true)
        print(UID)
        //self.tableView.reloadData()
    }
}


extension FindFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredSearches.count
        }
        return initial_users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
        if isFiltering{
            user = filteredSearches[indexPath.row]
        }else {
            user = initial_users[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        cell.setUser(user: user)
        cell.delegate = self
        
        return cell
    }
}

extension FindFriendsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

