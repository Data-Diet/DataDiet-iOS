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

class AccountViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var db: Firestore!
    var uid: String!
    var userData: DocumentReference!
    var image: UIImage? = nil
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var ProfilePhoto: UIImageView!
    
    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var Toolbar: UIToolbar!
    

    @IBAction func changeProfilePhoto(_ sender: Any) {
        // If change profile photo is clicked, use image picker to choose photo from library
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
            ProfilePhoto?.image = imageSelected
        }
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            image = imageOriginal
            ProfilePhoto?.image = imageOriginal
        }
        updateData()
        picker.dismiss(animated: true, completion: nil)
    }

    func updateData() {
        guard let imageSelected = self.image else {
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        // If profile photo was updated, store new one in Firebase storage
        let storageRef = Storage.storage().reference(forURL: "gs://datadiet-1329a.appspot.com")
        let storageProfileRef = storageRef.child("profile_pics").child(uid)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        storageProfileRef.putData(imageData, metadata: metadata, completion:
        { (storageMetaData, error) in
        if error != nil {
            return
        }
            storageProfileRef.downloadURL { (url, error) in
                if let metaImageUrl = url?.absoluteString{
                    // Update the profile photo url in Firebase database
                    self.userData.updateData(["profilePicURL": metaImageUrl]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
        } )
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
        // Get reference to account info document using uid of current user
        if let userID = Auth.auth().currentUser?.uid {
            userData = db.collection("users").document(userID)
            userData.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.uid = userID
                    let accountInfo = document.data()
                    
                    // Use document info to fill in name, email, and username labels
                    let firstName = (accountInfo!["first_name"] as! String)
                    let lastName = (accountInfo!["last_name"] as! String)
                    self.NameLabel?.text = (firstName + " " + lastName)
                    
                    self.EmailLabel?.text = (accountInfo!["email"] as! String)
                    self.UsernameLabel?.text = (accountInfo!["username"] as! String)
                    
                    // Use profile photo url to set the profile photo image view
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
