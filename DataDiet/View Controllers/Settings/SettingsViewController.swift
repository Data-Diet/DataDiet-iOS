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
import Hero

class SettingsViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet var Navbar: UINavigationBar!
    
    @IBOutlet var Toolbar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let IS = ImageSetter()
        
        IS.SetBarImage(Navbar: Navbar)
        IS.SetBarImage(Toolbar: Toolbar)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func OnBackButtonPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    
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
