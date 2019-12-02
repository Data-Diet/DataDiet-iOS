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
    var profilePhotos = [UIImage]()
    var defaultSelected: [String: Bool] = [:]
    var users: [User] = []
    
    @IBOutlet weak var FriendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        FriendsTableView.dataSource = self
        FriendsTableView.delegate = self

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
                            if let document = document, document.exists {
                                let username = document.data()?["username"] as! String
                                let firstName = document.data()?["first_name"] as! String
                                let lastName = document.data()?["last_name"] as! String
                                self.users.append(User(image:self.retrieveProfilePic(photoURLString: document.data()?["profilePicURL"] as! String)!, username: "@\(username)", fullname: "\(firstName) \(lastName)", UID: ""))
    
                                self.friendsUIDs.append(key as! String)
                                self.friendsSharedList.append(friendsKeyValues["\(key)"] as! Bool)
                                self.FriendsTableView.reloadData()
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        cell.setUser(user: user)
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(friendsSharedList[indexPath.row] , animated: true)
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
        
    func retrieveProfilePic(photoURLString : String) -> UIImage? {
        let photoURL = URL(string: photoURLString)
        let data = try? Data(contentsOf: photoURL!)
        if let imageData = data {
            let image = UIImage(data: imageData)!
            return image
        }
        return nil
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
}

