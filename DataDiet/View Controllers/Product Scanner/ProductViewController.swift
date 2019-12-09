//  ViewController.swift
//  SwiftJSONTutorial
//
//  Created by Belal Khan on 08/02/17.
//  Copyright © 2017 Belal Khan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchResultsUpdating {
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var IngredientTableView: UITableView!
    
    var db: Firestore!
    
    var productChecker = ProductChecker()
    
    let diets = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected = [Bool](repeating: false, count: 6)
    var allergyArray = [String]()
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
    var filteredIngredientsData = [String]()
    var resultSearchController = UISearchController()

    var productBarcode = ""
    var productTitleString = ""
    
    let ingredientGroup = DispatchGroup()
    let titleGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        IngredientTableView?.dataSource = self
        IngredientTableView?.delegate = self
        IngredientTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        
        let IS = ImageSetter()
        IS.SetBarImage(Navbar: Navbar)
        
        ingredientGroup.enter()
        titleGroup.enter()
        
        print("productBarcode: " + self.productBarcode)
        
        db = Firestore.firestore()
        
        let data = USDARequest()
        data.getTitle(barcodeNumber: self.productBarcode) { (title) in
            //Can access all the ingredients in here if barcode is specified
            self.productTitleString = title
            print(self.productIngredientsArray)
            self.titleGroup.leave()
        }
        
        data.getIngredients(barcodeNumber: self.productBarcode) { (ingredientsArray) in
            //Can access all the ingredients in here if barcode is specified
            print("self.allergyArray.count: ")
            print(self.allergyArray.count)
            if self.allergyArray.count > 0 {
                for ingredient in ingredientsArray {
                    for allergen in self.allergyArray {
                        if ingredient.lowercased().contains(allergen.lowercased()) {
                            self.productIngredientsArray.insert(ingredient, at: self.productIngredientsArray.startIndex)
                            break;
                        } else if (allergen == self.allergyArray[self.allergyArray.count - 1]){
                            self.productIngredientsArray.append(ingredient)
                        }
                    }
                }
            } else {
                self.productIngredientsArray = ingredientsArray
            }
            
            self.ingredientGroup.leave()
        }
        // does not wait. But the code in notify() gets run
        // after enter() and leave() calls are balanced
        
        titleGroup.notify(queue: .main) {
            self.productTitle.text = self.productTitleString
        }
        ingredientGroup.notify(queue: .main) {
            self.IngredientTableView.reloadData()
            self.allergensFound = self.productChecker.findAllergens(Ingredients: self.productIngredientsArray, Allergens: self.allergyArray)
            self.uploadToHistory()
            print(self.allergensFound)
        }
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()

            IngredientTableView.tableHeaderView = controller.searchBar

            return controller
        })()
        
        IngredientTableView.reloadData()
    }
    
    func uploadToHistory() {
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            let scannerData = db.collection("users").document(userID).collection("History").document(productBarcode)
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    scannerData.updateData(["product_title" : self.productTitleString, "found_diets" : [], "found_allergens" : self.allergensFound, "scan_time" : FieldValue.serverTimestamp(), "upc_number" : self.productBarcode, "scanned_allergens": self.allergyArray, "scanned_diets": []]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    scannerData.setData(["product_title" : self.productTitleString, "found_diets" : [], "found_allergens" : self.allergensFound, "scan_time" : FieldValue.serverTimestamp(), "upc_number" : self.productBarcode, "scanned_allergens": self.allergyArray, "scanned_diets": []]) { err in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredIngredientsData[indexPath.row]
        } else {
            cell.textLabel?.text = productIngredientsArray[indexPath.row]
        }
        
        for allergen in self.allergyArray {
            let ingredient = cell.textLabel?.text?.lowercased()
            print("ingredient: " + (ingredient ?? "nunt"))
            print("allergen: " + (allergen ?? "nunt"))
            if ingredient?.contains(allergen.lowercased()) ?? false {
                cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.textColor = UIColor.black 
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("productIngredientsArray.count: " + String(productIngredientsArray.count))
        if  (resultSearchController.isActive) {
            return filteredIngredientsData.count
        } else {
            return productIngredientsArray.count
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredIngredientsData.removeAll(keepingCapacity: false)

        let searchPredicate = NSPredicate(format: "SELF contains[cd] %@", searchController.searchBar.text!)
        let array = (productIngredientsArray as NSArray).filtered(using: searchPredicate)
        filteredIngredientsData = array as! [String]

        self.IngredientTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
