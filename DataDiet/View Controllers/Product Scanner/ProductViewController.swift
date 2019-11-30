//  ViewController.swift
//  SwiftJSONTutorial
//
//  Created by Belal Khan on 08/02/17.
//  Copyright © 2017 Belal Khan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var IngredientTableView: UITableView!
    
    var db: Firestore!
    
    var productChecker = ProductChecker()
    
    let diets = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected = [Bool](repeating: false, count: 6)
    var alleryArray = [String]()
    let defaultSettings: [String: Any] = [
           "Vegan": false,
           "Vegetarian": false,
           "Pescatarian": false,
           "Kosher": false,
           "Ketogenic": false,
           "Paleolithic": false,
           "Allergies": [String]()
       ]
    var allergensFound = [String]()
    
    let SegueIdProductJSON = "productJSON"
    
    var productIngredientsArray = [String]()
    var productBarcode = ""
    var productTitleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        IngredientTableView?.dataSource = self
        IngredientTableView?.delegate = self
        IngredientTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        
        let IS = ImageSetter()
        IS.SetBarImage(Navbar: Navbar)
        
        let ingredientGroup = DispatchGroup()
        let titleGroup = DispatchGroup()
        ingredientGroup.enter()
        titleGroup.enter()
        
        print("productBarcode: " + self.productBarcode)
        
        db = Firestore.firestore()
        loadDietsAndAllergens()
        
        let data = USDARequest()
        data.getTitle(barcodeNumber: self.productBarcode) { (title) in
            //Can access all the ingredients in here if barcode is specified
            self.productTitleString = title
            print(self.productIngredientsArray)
            titleGroup.leave()
        }
        
        data.getIngredients(barcodeNumber: self.productBarcode) { (ingredientsArray) in
            //Can access all the ingredients in here if barcode is specified
            self.productIngredientsArray = ingredientsArray
            print(self.productIngredientsArray)
            ingredientGroup.leave()
        }

        // does not wait. But the code in notify() gets run
        // after enter() and leave() calls are balanced
        
        titleGroup.notify(queue: .main) {
            self.productTitle.text = self.productTitleString
        }
        ingredientGroup.notify(queue: .main) {
            self.IngredientTableView.reloadData()
            self.allergensFound = self.productChecker.findAllergens(Ingredients: self.productIngredientsArray, Allergens: self.alleryArray)
            self.uploadToHistory()
            print(self.allergensFound)
        }
    }
    
    func loadDietsAndAllergens() {
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            let scannerData = db.collection("users").document(userID).collection("Settings").document("Scanner")
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let scannerSettings = document.data()
                    for i in 0 ... self.diets.count - 1 {
                        self.dietsSelected[i] = scannerSettings![self.diets[i]] as! Bool
                    }
                    self.alleryArray = scannerSettings!["Allergies"] as! [String]
                }
                else {
                    scannerData.setData(self.defaultSettings) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }
    
    func uploadToHistory() {
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            let scannerData = db.collection("users").document(userID).collection("History").document(productBarcode)
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    scannerData.updateData(["found_diets" : [], "found_allergens" : self.allergensFound, "scan_time" : FieldValue.serverTimestamp(), "upc_number" : self.productBarcode, "scanned_allergens": self.alleryArray, "scanned_diets": []]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    scannerData.setData(["found_diets" : [], "found_allergens" : self.allergensFound, "scan_time" : FieldValue.serverTimestamp(), "upc_number" : self.productBarcode, "scanned_allergens": self.alleryArray, "scanned_diets": []]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell")!
        cell.textLabel?.text = productIngredientsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("productIngredientsArray.count: " + String(productIngredientsArray.count))
        return productIngredientsArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
