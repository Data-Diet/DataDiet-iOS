//
//  HistoryViewController.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/26/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var productsScanned = [Product]()
    var db: Firestore!
    var collectionRef: CollectionReference!
    var productBarcode = String()
    
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

    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var Toolbar: UIToolbar!
    @IBOutlet weak var HistoryTableView: UITableView!
    
    @IBAction func clearHistory(_ sender: Any) {
        // Display an alert when clear is pressed to confirm that the user wanted to clear their history
        let alert = UIAlertController(title: "Clear history?", message: "Clearing history will remove all scanned product details and you will not be able to recover them.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear", style: UIAlertAction.Style.default, handler: { action in
            
            // If clear is confirmed, delete all documents in history collection and update UI to show empty history
            for i in 0 ... self.productsScanned.count - 1 {
                let docToDelete = self.productsScanned[i].upc
                self.collectionRef.document(docToDelete).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
            self.productsScanned = [Product]()
            self.HistoryTableView.reloadData()
            
            }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        loadDietsAndAllergens()

        HistoryTableView.dataSource = self
        HistoryTableView.delegate = self
        
        let IS = ImageSetter()
        
        IS.SetBarImage(Navbar: Navbar)
        IS.SetBarImage(Toolbar: Toolbar)
    
        loadHistory()
    }

    func loadHistory() {
        // Get reference to history collection for the current user using their uid
        if let userID = Auth.auth().currentUser?.uid {
            collectionRef = db.collection("users").document(userID).collection("History")
            collectionRef.getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if (snapshot?.isEmpty)! {
                    print("No history to display")
                } else {
                    // Populate array of products scanned with details from each product document in the history collection
                    for document in (snapshot?.documents)! {
                        let productTitle = document.data()["product_title"] as! String
                        let upcNumber = document.data()["upc_number"] as! String
                        let scannedDiets = document.data()["scanned_diets"] as! [String]
                        let scannedAllergens = document.data()["scanned_allergens"] as! [String]
                        let foundDiets = document.data()["found_diets"] as! [String]
                        let foundAllergens = document.data()["found_allergens"] as! [String]
                        self.productsScanned.append(Product(title: productTitle, upc: upcNumber, dietsScanned: scannedDiets, allergensScanned: scannedAllergens, dietsFound: foundDiets, allergensFound: foundAllergens))
                    }
                    print(self.productsScanned)
                }
                // Reload the history table view to reflect the information in the products scanned array
                self.HistoryTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsScanned.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryTableViewCell
        // Use details of product scanned to set the cell labels
        cell.setProductDetails(product: productsScanned[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.HistoryTableView && editingStyle == .delete {
            // If the user deletes a product, remove the product from the products scanned array, update UI with deleted row, and delete the product document from the history collection
            let docToDelete = productsScanned[indexPath.row].upc
            productsScanned.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
    
            collectionRef.document(docToDelete).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Display an alert when a product is clicked on to confirm that the user wanted to rescan that product for their current scanner settings
           let alert = UIAlertController(title: "Rescan product?", message: "Rescanning this product with your current scanner settings will replace the previous product details.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Rescan", style: UIAlertAction.Style.default, handler: { action in
            // If rescan is confirmed, pass the product's upc number to the product activity for rescanning
            
            self.productBarcode = self.productsScanned[indexPath.row].upc
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "History", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "HistoryProductView") as! ProductViewController

                controller.productBarcode = self.productBarcode
                controller.allergyArray = self.allergyArray
                controller.hero.modalAnimationType = .push(direction: .left)
                self.present(controller, animated: true, completion: nil)
            }
        
            }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadDietsAndAllergens() {
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            let scannerData = db.collection("users").document(userID).collection("Settings").document("Scanner")
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let scannerSettings = document.data()
                    self.allergyArray = scannerSettings!["Allergies"] as! [String]
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
    
    @IBAction func OnBackButtonPressed(_ sender: Any) {
        if let ScannerVC = UIStoryboard(name: "Scanner", bundle: nil).instantiateViewController(withIdentifier: "ScannerView") as? ScannerViewController
        {
            ScannerVC.hero.modalAnimationType = .push(direction: .up)
            present(ScannerVC, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductViewSegue") {
            let ProductVC = segue.destination as! ProductViewController
            ProductVC.productBarcode = self.productBarcode
            ProductVC.allergyArray = self.allergyArray
            ProductVC.hero.modalAnimationType = .push(direction: .left)
        }
    }

}
