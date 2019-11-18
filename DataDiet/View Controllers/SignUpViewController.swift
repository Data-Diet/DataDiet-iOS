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
import FirebaseStorage

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.alpha = 0
        // initialize image view
        profilePic.layer.cornerRadius = 50
        profilePic.clipsToBounds = true
        profilePic.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        profilePic.addGestureRecognizer(tapGesture)
        
        usernameTextField.addTarget(self, action: #selector(doesUsernameExist), for: .editingDidEnd)

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
    @objc func doesUsernameExist(){
        if usernameTextField.text?.isEmpty == false {
            usernameTextField.checkUsername(field: usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                (success) in
                if success == true {
                    print("Username already exist!")
                    self.showError("Username already exist!")
                } else{
                    print("Username is not taken")
                    self.errorLabel.text = ""
                    }
                }
        }
    }

    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            image = imageSelected
            profilePic.image = imageSelected
        }
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            image = imageOriginal
            profilePic.image = imageOriginal
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func isPasswordValid(_ password: String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")
        return passwordTest.evaluate(with: password)
    }
    
    func isUsernameValid(_ username: String) -> Bool {
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", "^(?!.*\\.\\.)(?!.*\\.$)[^\\W][\\w.]{3,29}$")
        return usernameTest.evaluate(with: username)
    }
    
    // set Error Message on View Controller
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func validateFields() -> String? {
        var error: String? = nil
        // Check all fields are filled in.
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = "Please fill in all fields"
            return error
        }
        // Check that password and confirmed password are the same
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if confirmPassword != cleanedPassword {
            error = "Please make sure your passwords match!"
            return error
        }
        // Check if password is strong enough
        if isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            error = "Your password is not strong enough!"
            return error
        }
        // Check if username is valid length
        let cleanedUsername = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isUsernameValid(cleanedUsername) == false {
            error = "Not a valid username!"
            return error
        }

        return error
    }
    
    func transitionToHome(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SignUpSuccessSegue", sender: self)
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else if errorLabel.text == "Username already exist!"{
            print("Not signing in")
        }else {
            // Create cleaned version of data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = usernameTextField.text!.trimmingCharacters(in:
                .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let imageSelected = self.image else {
                print("Picture is nil")
                return
            }
            guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                return
            }
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result,err) in
                // Check for errors
                if err != nil {
                    // There was error creating user
                    self.showError("Error creating user!")
                } else {
                    // Make storage reference to Firebase Storage
                    let storageRef = Storage.storage().reference(forURL: "gs://datadiet-1329a.appspot.com")
                    let storageProfileRef = storageRef.child("profile_pics").child(result!.user.uid)
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpg"
                    // Store picture to Firebase
                    storageProfileRef.putData(imageData, metadata: metadata, completion:
                        { (storageMetaData, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                            return
                        }
                            storageProfileRef.downloadURL { (url, error) in
                                if let metaImageUrl = url?.absoluteString{
                                    print(metaImageUrl)
                                    // User created successfully, now store first and last name
                                    let db = Firestore.firestore()
                                    db.collection("users").document(result!.user.uid).setData(["first_name" : firstName, "last_name" : lastName, "username" : username, "profilePicURL" : metaImageUrl, "email" : email])
                                    db.collection("users").document(result!.user.uid).collection("Settings").addDocument(data: ["Ketogenic" : false, "Vegetarian" : false]) { (error) in
                                        if err != nil {
                                            self.showError("Error creating database")
                                        }
                                        }
                                }
                            }
                    } )
                    // Transition to home screen
                    self.transitionToHome()
                }
            }
        }
    }
}

extension UITextField {
    func checkUsername(field: String, completion: @escaping (Bool) -> Void){
        // get reference to users collection
        let collectionRef = Firestore.firestore().collection("users")
        // query for all keys in document field that contain username and grab all their fields
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
