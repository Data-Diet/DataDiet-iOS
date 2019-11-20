//
//  AccountViewController.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/14/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AccountViewController: UIViewController {

    var db: Firestore!
    
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var ProfilePhoto: UIImageView!
    
    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var Toolbar: UIToolbar!
    
    
    @IBAction func changeProfilePhoto(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let IS = ImageSetter()
        
        if (Navbar != nil) {
            IS.SetBarImage(Navbar: Navbar)
            IS.SetBarImage(Toolbar: Toolbar)
        }
        
        ProfilePhoto?.layer.masksToBounds = true
        ProfilePhoto?.layer.cornerRadius = ProfilePhoto.bounds.width / 2
        db = Firestore.firestore()
        loadInfo()
    }
    
    func loadInfo() {
        if let userID = Auth.auth().currentUser?.uid {
            let scannerData = db.collection("users").document(userID)
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let accountInfo = document.data()
                    
                    let firstName = (accountInfo!["first_name"] as! String)
                    let lastName = (accountInfo!["last_name"] as! String)
                    self.NameLabel?.text = (firstName + " " + lastName)
                    
                    self.EmailLabel?.text = (accountInfo!["email"] as! String)
                    self.UsernameLabel?.text = (accountInfo!["username"] as! String)
                    
                    let photoURLString = (accountInfo!["profilePicURL"] as! String)
                    let photoURL = URL(string: photoURLString)
                    let data = try? Data(contentsOf: photoURL!)
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        self.ProfilePhoto?.image = image
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}
