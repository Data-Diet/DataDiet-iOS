//
//  EditEmailViewController.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/25/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditEmailViewController: UIViewController {
    
    var db: Firestore!
    var userData: DocumentReference!

   
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBAction func onDoneTapped(_ sender: Any) {
        let newEmail = EmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if newEmail == "" {
            ErrorLabel.alpha = 1
        } else {
            ErrorLabel.alpha = 0
            userData.updateData(["email": newEmail as Any]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "EmailEditedSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ErrorLabel.alpha = 0
        db = Firestore.firestore()
        loadInfo()
    }

    func loadInfo() {
        if let userID = Auth.auth().currentUser?.uid {
            userData = db.collection("users").document(userID)
            userData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let accountInfo = document.data()
                    let email = (accountInfo!["email"] as! String)
                    self.EmailTextField.text = email
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

}
