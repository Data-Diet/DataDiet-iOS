//
//  PersonalSettingsViewController.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/13/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PersonalSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let diets = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected = [Bool](repeating: false, count: 6)
    var allergies = [String]()
    var db: Firestore!
    var scannerData: DocumentReference!
    let defaultSettings: [String: Any] = [
        "Vegan": false,
        "Vegetarian": false,
        "Pescatarian": false,
        "Kosher": false,
        "Ketogenic": false,
        "Paleolithic": false,
        "Allergies": [String]()
    ]
    
    @IBOutlet weak var DietsTableView: UITableView!
    @IBOutlet weak var AllergiesTextField: UITextField!
    @IBOutlet weak var AllergiesTableView: UITableView!
    
    @IBAction func addAllergy(_ sender: Any) {
        allergies.append(AllergiesTextField.text!)
        let indexPath = IndexPath(row: allergies.count - 1, section: 0)
        AllergiesTableView.beginUpdates()
        AllergiesTableView.insertRows(at: [indexPath], with: .automatic)
        AllergiesTableView.endUpdates()
        AllergiesTextField.text = ""
        view.endEditing(true)
        
        scannerData.updateData(["Allergies": allergies]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DietsTableView.dataSource = self
        DietsTableView.delegate = self
        DietsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DietCell")
        
        AllergiesTableView.dataSource = self
        AllergiesTableView.delegate = self
        AllergiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AllergyCell")
        
        db = Firestore.firestore()
        loadSettings()
    }

    func loadSettings() {
        if let userID = Auth.auth().currentUser?.uid {
            scannerData = db.collection("users").document(userID).collection("Settings").document("Personal")
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let scannerSettings = document.data()
                    for i in 0 ... self.diets.count - 1 {
                        self.dietsSelected[i] = scannerSettings![self.diets[i]] as! Bool
                    }
                    self.allergies = scannerSettings!["Allergies"] as! [String]
                } else {
                    self.scannerData.setData(self.defaultSettings) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
                self.DietsTableView.reloadData()
                self.AllergiesTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.DietsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DietCell")!
            cell.textLabel?.text = diets[indexPath.row]
        
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(dietsSelected[indexPath.row], animated: true)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
            cell.accessoryView = switchView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllergyCell")!
            cell.textLabel?.text = allergies[indexPath.row]
            return cell
        }
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        dietsSelected[sender.tag] = sender.isOn;
        scannerData.updateData([diets[sender.tag]: sender.isOn]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == self.DietsTableView {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.DietsTableView {
            return diets.count
        }
        return allergies.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.AllergiesTableView && editingStyle == .delete {
            allergies.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            scannerData.updateData(["Allergies": allergies]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
}
