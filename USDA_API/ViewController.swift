//
//  ViewController.swift
//  USDA_API
//
//  Created by Kenneth Mai on 10/29/19.
//  Copyright © 2019 Kenneth Mai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let data = USDARequest()
        data.getIngredients(barcodeNumber: "00028400157483") { (ingredientsArray) in
            //Can access all the ingredients in here if barcode is specified
            for element in ingredientsArray { //Testing
                print(element)
            }
        }
    }
    
}
