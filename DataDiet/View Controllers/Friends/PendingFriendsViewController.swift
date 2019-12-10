//
//  PendingFriendsViewController.swift
//  DataDiet
//
//  Created by Eric Zamora on 11/30/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import Hero

class PendingFriendsViewController: UIViewController {
    let VT = ViewTransitioner()
    
    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        createArray()

        // test
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
        var idArray: [String] = []
        // grab document containing all UIDs of users that are sending pending requests
        let pendingRef = Firestore.firestore().collection("users").document(currentUID).collection("Friends").document("Pending")
        pendingRef.getDocument { (document, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else if let document = document, document.exists{
                let friendsKeyValues: NSDictionary = document.data()! as NSDictionary
                for (key, _) in friendsKeyValues {
                    idArray.append(key as! String)
                }
                // query for all documents under the "users" collection
                collectionRef.getDocuments { (snapshot, err) in
                        if let err = err {
                            print("Error getting document: \(err)")
                        } else if (snapshot?.isEmpty)!{
                            print("No users here")
                        } else {
                            // if documents exist push to array
                            for document in (snapshot?.documents)!{
                                if currentUID != document.documentID && idArray.contains(document.documentID) {
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
                
                
            } else {
                print("Document does not exist")
            }
        }
        // query for all documents under the "users" collection
        /*collectionRef.getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else if (snapshot?.isEmpty)!{
                    print("No users here")
                } else {
                    // if documents exist push to array
                    for document in (snapshot?.documents)!{
                        if currentUID != document.documentID{
                            let username = document.data()["username"] as! String
                            let firstName = document.data()["first_name"] as! String
                            let lastName = document.data()["last_name"] as! String
                            let UID = document.documentID
                            self.users.append(User(image:self.retrieveProfilePic(document)!, username: "@\(username)", fullname: "\(firstName) \(lastName)", UID: UID))
                            }
                        }
                    }
                self.tableView.reloadData()
                }*/
    }

    @IBAction func OnBackButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsView") as! SettingsViewController
        self.present(controller, animated: true, completion: nil)
    }

}

extension PendingFriendsViewController: PendingCellDelegate {
    func didTapAccept(UID: String, cell: UITableViewCell) {
        let currentUID: String! = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        // check if user exist in friends list if it does then don't send friend request
        db.collection("users").document(currentUID).collection("Friends").document("FriendList").setData([UID : false], merge: true)
        db.collection("users").document(UID).collection("Friends").document("FriendList").setData([currentUID : false], merge: true)
        db.collection("users").document(currentUID).collection("Friends").document("FriendSelected").setData([UID : false], merge: true)
        db.collection("users").document(UID).collection("Friends").document("FriendSelected").setData([currentUID : false], merge: true)
        db.collection("users").document(currentUID).collection("Friends").document("Pending").updateData([UID : FieldValue.delete()])

        print(UID)
        if let indexPath = tableView.indexPath(for: cell) {
            users.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            print("Button tapped at \(indexPath)")
        }
        //self.tableView.reloadData()
    }
}

extension PendingFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
            user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingCell") as! PendingCell
        cell.setUser(user: user)
        cell.delegate = self
        
        return cell
    }
}
