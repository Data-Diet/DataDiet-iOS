//
//  ScannerSettingsController.swift
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
    
    //Used to store friend's personal settings
    let diets1 = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected1 = [Bool](repeating: false, count: 6)
    var allergies1 = [String]()
    
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
            db.collection("users").document(userID).collection("Friends").getDocuments() { (snapShot, error) in
                
                //Retrieve friend's uid and sharing status to other friends from firebase
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in snapShot!.documents {
                        let friendsKeyValues: NSDictionary = document.data() as NSDictionary
                        for (key, _) in friendsKeyValues {
                            //Use the userUID to collect friend's sharing statuses and construct friend names (Pioritizes usernames)
                            self.db.collection("users").document(key as! String).getDocument() { (document, error) in
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
                
                //Retrieve personal settings and share settings with friend
                self.scannerData = self.db.collection("users").document(userID).collection("Settings").document("Personal")
                self.scannerData.getDocument() { (document, error) in
                    if let document = document, document.exists {
                        let scannerSettings = document.data()
                            for i in 0 ... self.diets.count - 1 {
                                self.dietsSelected[i] = scannerSettings![self.diets[i]] as! Bool
                            }
                            self.allergies = scannerSettings!["Allergies"] as! [String]
                    } else {
                        self.scannerData.setData(self.defaultSettings) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
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
            var i = 0
            let friendDoc = db.collection("users").document(userID).collection("Friends").document("FriendList")
            
            //Update firebase if you want to share or unshare settings with friend
            for friend in friendsUIDs {
                friendDoc.updateData([friend: friendsSharedList[i]])
                i = (i + 1) % friendsUIDs.count
            }
        
            //If sharing -> update current scanner of friends with your personal settings
            let currentScanner = db.collection("users").document(friendsUIDs[sender.tag]).collection("Settings").document("Current")
            if(friendsSharedList[sender.tag] == true) {
                 currentScanner.updateData(["Allergies" : allergies])
                 for j in 0...diets.count-1 {
                     currentScanner.updateData([diets[j]: dietsSelected[j]])
                 }
            } else {
                //If unshared -> Retrieve friend's personal settings and load it into his current scanner
                let friendsPersonalData = db.collection("users").document(friendsUIDs[sender.tag]).collection("Settings").document("Personal")
                friendsPersonalData.getDocument() { (document, error) in
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
        }
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendNames.count
    }
    
}
