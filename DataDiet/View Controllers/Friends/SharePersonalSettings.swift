//
//  SharePersonalSettings.swift
//  DataDiet
//
//  Created by Kenneth Mai on 11/13/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SharePersonalSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db: Firestore!
    var scannerData: DocumentReference!
    var friendsUIDs = [String]()
    var friendNames = [String]()
    var friendsSharedList = [Bool]()    
    var defaultSelected: [String: Bool] = [:]
    
    @IBOutlet weak var FriendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        FriendsTableView.dataSource = self
        FriendsTableView.delegate = self
        FriendsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
        
        db = Firestore.firestore()
        shareFriends()
    }
    
    func shareFriends() {
        if let userID = Auth.auth().currentUser?.uid {
            let friendsList = db.collection("users").document(userID).collection("Friends").document("FriendList")
            friendsList.getDocument() { (document, error) in
                if let document = document, document.exists {
                    let friendsKeyValues: NSDictionary = document.data()! as NSDictionary
                    
                    //Query all of user's friends
                    for (key, _) in friendsKeyValues {
                        self.db.collection("users").document(key as! String).getDocument() { (document, error) in
                            
                            //construct friend names (Pioritizes usernames)
                            if let document = document, document.exists {
                                let name: Dictionary = document.data()! as Dictionary
                                if(name["username"] != nil) {
                                    self.friendNames.append(name["username"] as! String)
                                } else {
                                    self.friendNames.append("\(name["first_name"] as! String)" + " \(name["last_name"] as! String)")
                                }
                            } else {
                                print("Document does not exist")
                            }
                            self.friendsUIDs.append(key as! String)
                            self.friendsSharedList.append(friendsKeyValues["\(key)"] as! Bool)
                            self.FriendsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell")!
        cell.textLabel?.text = friendNames[indexPath.row]
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(friendsSharedList[indexPath.row], animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        friendsSharedList[sender.tag] = sender.isOn;
        
        if let userID = Auth.auth().currentUser?.uid {
            let friendDoc = db.collection("users").document(userID).collection("Friends").document("FriendList")
            friendDoc.updateData([friendsUIDs[sender.tag]: sender.isOn])
            
            //Create an ongoing list of people who have shared with friend
            let UsersWhoHaveShared = db.collection("users").document(friendsUIDs[sender.tag]).collection("Friends").document("UsersWhoHaveShared")
            UsersWhoHaveShared.getDocument() { (document, error) in
                if let document = document, document.exists {
                    UsersWhoHaveShared.updateData([userID: sender.isOn])
                } else {
                    UsersWhoHaveShared.setData([userID : sender.isOn])
                }
            }
            
        }
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendNames.count
    }
    
}
