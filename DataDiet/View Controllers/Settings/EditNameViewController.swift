//
//  EditNameViewController.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/25/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditNameViewController: UIViewController {
    
    var db: Firestore!
    var userData: DocumentReference!

    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBAction func onDoneTapped(_ sender: Any) {
        let newFirstName = FirstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let newLastName = LastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if newFirstName == "" || newLastName == "" {
            ErrorLabel.alpha = 1
        } else {
            ErrorLabel.alpha = 0
            userData.updateData(["first_name": newFirstName as Any]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            userData.updateData(["last_name": newLastName as Any]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "NameEditedSegue", sender: self)
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
                    let firstName = (accountInfo!["first_name"] as! String)
                    let lastName = (accountInfo!["last_name"] as! String)
                    self.FirstNameTextField.text = firstName
                    self.LastNameTextField.text = lastName
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

}
