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

    @IBOutlet weak var HistoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HistoryTableView.dataSource = self
        HistoryTableView.delegate = self
        
        db = Firestore.firestore()
        loadHistory()
    }

    func loadHistory() {
        if let userID = Auth.auth().currentUser?.uid {
            collectionRef = db.collection("users").document(userID).collection("History")
            collectionRef.getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if (snapshot?.isEmpty)! {
                    print("No history to display")
                } else {
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
                self.HistoryTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsScanned.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryTableViewCell
        cell.setProductDetails(product: productsScanned[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.HistoryTableView && editingStyle == .delete {
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

}
