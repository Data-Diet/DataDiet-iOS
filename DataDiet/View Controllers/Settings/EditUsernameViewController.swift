//
//  EditUsernameViewController.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/25/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditUsernameViewController: UIViewController {
    
    var db: Firestore!
    var userData: DocumentReference!

    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBAction func onDoneTapped(_ sender: Any) {
        let newUsername = UsernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if newUsername == "" {
            ErrorLabel.text = "Field is required"
        } else if !isValidUsername(newUsername!) {
            ErrorLabel.text = "Username is invalid"
        } else if ErrorLabel.text != "Username already exists" {
            ErrorLabel.text = ""
            userData.updateData(["username": newUsername as Any]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "UsernameEditedSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ErrorLabel.text = ""
        db = Firestore.firestore()
        loadInfo()
        UsernameTextField.addTarget(self, action: #selector(checkIfUsernameExists), for: .editingChanged)
    }
    
    func loadInfo() {
        if let userID = Auth.auth().currentUser?.uid {
            userData = db.collection("users").document(userID)
            userData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let accountInfo = document.data()
                    let username = (accountInfo!["username"] as! String)
                    self.UsernameTextField.text = username
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", "^(?!.*\\.\\.)(?!.*\\.$)[^\\W][\\w.]{2,29}$")
        return usernameTest.evaluate(with: username)
    }
    
    @objc func checkIfUsernameExists(){
        if UsernameTextField.text?.isEmpty == false {
            UsernameTextField.usernameExists(field: UsernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                (success) in
                if success == true {
                    self.ErrorLabel.text = "Username already exists"
                } else {
                    self.ErrorLabel.text = ""
                }
            }
        }
    }
}

extension UITextField {
    func usernameExists(field: String, completion: @escaping (Bool) -> Void){
        let collectionRef = Firestore.firestore().collection("users")
                collectionRef.whereField("username", isEqualTo: field).getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else if (snapshot?.isEmpty)!{
                    completion(false)
                } else {
                    for document in (snapshot?.documents)!{
                        if document.data()["username"] != nil{
                            print("\(document.documentID) =>  \(document.data())")
                            completion(true)
                        }
                    }
                }
            }
    }
}
