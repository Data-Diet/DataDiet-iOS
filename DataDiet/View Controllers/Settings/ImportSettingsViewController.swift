//
//  ImportSettingsController.swift
//  DataDiet
//
//  Created by Kenneth Mai on 11/26/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ImportSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db: Firestore!
    var scannerData: DocumentReference!
    var friendsUIDs = [String]()
    var friendNames = [String]()
    var friendSelected = [Bool]()
    var profilePhotos = [UIImage]()
    var defaultSelected: [String: Bool] = [:]
    var users: [ShareUser] = []
    
    //Used to store friend's personal settings
    let diets = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected = [Bool](repeating: false, count: 6)
    var allergies = [String]()
    let defaultSettings: [String: Any] = [
        "Vegan": false,
        "Vegetarian": false,
        "Pescatarian": false,
        "Kosher": false,
        "Ketogenic": false,
        "Paleolithic": false,
        "Allergies": [String]()
    ]
    
    //Used to store user's personal settings just in case no friend is selected
    let diets1 = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected1 = [Bool](repeating: false, count: 6)
    var allergies1 = [String]()
    
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
            let friendsList = db.collection("users").document(userID).collection("Friends").document("UsersWhoHaveShared")
            
            friendsList.getDocument() { (document, error) in
                if let document = document, document.exists {
                    
                    let friendsKeyValues: NSDictionary = document.data()! as NSDictionary
                    
                    //Query all of user's friends
                    for (key, _) in friendsKeyValues {
                        self.db.collection("users").document(key as! String).getDocument() { (document, error) in
                            //Check if friend has shared with user
                            if(friendsKeyValues["\(key)"] as! Bool == true) {
                                if let document = document, document.exists {
                                   let username = document.data()?["username"] as! String
                                   let firstName = document.data()?["first_name"] as! String
                                   let lastName = document.data()?["last_name"] as! String
                                    
                                   self.users.append(ShareUser(image:self.retrieveProfilePic(photoURLString: document.data()?["profilePicURL"] as! String)!, username: "@\(username)", fullname: "\(firstName) \(lastName)"))
                                   self.friendsUIDs.append(key as! String)
                                } else {
                                    print("Document does not exist")
                                }
                            }
                        }
                    }
                    //Retreive the friend that the user wants to have imported into scanner
                    self.fetchFriendSelected(userID : userID)
                    self.FriendsTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareFriendCell") as! ShareFriendCell
        cell.setShareUser(user: user)
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(friendSelected[indexPath.row] , animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.importSettings(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    @objc func importSettings(_ sender: UISwitch!) {
        friendSelected[sender.tag] = sender.isOn;
        
        if let userID = Auth.auth().currentUser?.uid {
            //If one switch is toggled, need to turn off others
            selectOneSwitchOnly(userID: userID, senderTag: sender.tag, senderIsOn: sender.isOn)
            
            //If pressed -> update user's current scanner to friend's personal settings
            if(friendSelected[sender.tag] == true) {
                fetchFriendPersonalSettings(userID: userID, senderTag: sender.tag)
            } else {
                //If unpressed -> Grab user's personal settings and load into user scanner
                fetchUserPersonalSettings(userID: userID)
            }
        }
    }
    
    func selectOneSwitchOnly(userID : String, senderTag : Int, senderIsOn : Bool) {
        let friendDoc = db.collection("users").document(userID).collection("Friends").document("FriendSelected")
        for i in 0...friendSelected.count - 1 {
            if(i != senderTag) {
                friendSelected[i] = false
                friendDoc.updateData([friendsUIDs[i]: false])
                FriendsTableView.reloadData()
            } else {
                friendDoc.updateData([friendsUIDs[senderTag]: senderIsOn])
            }
        }
    }
    
    func fetchFriendPersonalSettings(userID : String, senderTag : Int) {
        let currentScanner = db.collection("users").document(userID).collection("Settings").document("Scanner")
        if(friendSelected[senderTag] == true) {
            //Retrieve personal settings of friend
            self.scannerData = self.db.collection("users").document(friendsUIDs[senderTag]).collection("Settings").document("Personal")
            self.scannerData.getDocument() { (document, error) in
                if let document = document, document.exists {
                    let scannerSettings = document.data()
                    for i in 0 ... self.diets.count - 1 {
                        self.dietsSelected[i] = scannerSettings![self.diets[i]] as! Bool
                    }
                    self.allergies = scannerSettings!["Allergies"] as! [String]
                }
                //Load data into user scanner
                currentScanner.updateData(["Allergies" : self.allergies])
                for j in 0...self.diets.count-1 {
                    currentScanner.updateData([self.diets[j]: self.dietsSelected[j]])
                }
            }
        }
    }
        
    func fetchUserPersonalSettings(userID : String) {
        let currentScanner = db.collection("users").document(userID).collection("Settings").document("Scanner")
        let personalSettings = db.collection("users").document(userID).collection("Settings").document("Personal")
        personalSettings.getDocument() { (document, error) in
            if let document = document, document.exists {
                let scannerSettings = document.data()
                for i in 0 ... self.diets1.count - 1 {
                    self.dietsSelected1[i] = scannerSettings![self.diets[i]] as! Bool
                }
                self.allergies1 = scannerSettings!["Allergies"] as! [String]
            }
            currentScanner.updateData(["Allergies" : self.allergies1])
            for j in 0...self.diets.count-1 {
                currentScanner.updateData([self.diets[j]: self.dietsSelected1[j]])
            }
        }
    }

    func fetchFriendSelected(userID : String) {
        let friendSelected = self.db.collection("users").document(userID).collection("Friends").document("FriendSelected")
        friendSelected.getDocument() { (document, error) in
            if let document = document, document.exists {
                let name: Dictionary = document.data()! as Dictionary
                for id in self.friendsUIDs {
                    if(name[id] != nil) {
                        self.friendSelected.append(name[id] as! Bool)
                        self.FriendsTableView.reloadData()
                    }
                }
            } else {
                friendSelected.setData(self.defaultSelected)
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

