//
//  SignUpViewController.swift
//  DataDiet
//
//  Created by Eric Zamora on 10/21/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.alpha = 0

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Check the fields and validate that the data is correct.
    // if everything is correct then this method returns nil otherwise it returns the error message as a string to give error label
    func isPasswordValid(_ password: String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    // set Error Message on View Controller
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func validateFields() -> String? {
        // Check all fields are filled in.
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        // Check if password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number"
        }
        
        return nil
    }
    
    func transitionToHome(){
        let homeVC = storyboard?.instantiateViewController(identifier: Constants.Storyboard.ScannerController) as? ScannerController
        
        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
    }
    
    

    
    @IBAction func signUpTapped(_ sender: Any) {
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            
            // Create cleaned version of data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result,err) in
                // Check for errors
                if err != nil {
                    // There was error creating user
                    self.showError("Error creating user!")
                } else {
                    // User created successfully, now store first and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["first_name" : firstName, "last_name" : lastName, "UID" : result!.user.uid]) { (error) in
                        if err != nil {
                            // Show error message
                            self.showError("Error creating this user!")
                        }
                    }
                    // Transition to home screen
                    self.transitionToHome()
                }
            }
        }
    }
}
