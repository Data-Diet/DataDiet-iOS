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

class FindFriendsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //users = [User(image: #imageLiteral(resourceName:"LoginIcon"), username: "Your Firsts", fullname: "Eric Zamora")]
        createArray()
        
        // Do any additional setup after loading the view.
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
            // query for all documents under the "users" collection
        collectionRef.getDocuments { (snapshot, err) in
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
                            self.users.append(User(image:self.retrieveProfilePic(document)!, username: "@\(username)", fullname: "\(firstName) \(lastName)"))
                            }
                        }
                    }
                self.tableView.reloadData()
                }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension FindFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        print("HELLO HI I DID IT \(user)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        cell.setUser(user: user)
        
        return cell
    }
}

