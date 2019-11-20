//
//  ImportSettingsViewController.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 11/20/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

class ImportSettingsViewController: UIViewController {

    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var Toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let IS = ImageSetter()
        
        IS.SetBarImage(Navbar: Navbar)
        IS.SetBarImage(Toolbar: Toolbar)
        
        
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

}
