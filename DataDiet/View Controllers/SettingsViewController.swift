//
//  SettingsViewController.swift
//  DataDiet
//
//  Created by Eric Zamora on 11/7/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class SettingsViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

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

    
    
    @IBAction func logOutTapped(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //DispatchQueue.main.async {
                //self.performSegue(withIdentifier: "loggedOut", sender: self)}
            //navigationController?.popToRootViewController(animated: true)
            //let navController = UINavigationController(rootViewController: //LoginViewController())
            //navController.navigationBar.barStyle = .black
            //self.present(navController, animated: true, completion: nil)
            performSegue(withIdentifier: "LogOutSegue", sender: sender)
            print("Logged OUT")
        }catch let signOutError as NSError{
                print("Error signing out: %@", signOutError)
            }
    }
}
