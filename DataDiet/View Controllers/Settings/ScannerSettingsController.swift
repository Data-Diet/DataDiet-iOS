//
//  ScannerSettingsController.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 10/18/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import Hero


class ScannerSettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let VT = ViewTransitioner()
    
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
    @IBOutlet weak var AddAllergyButton: UIButton!
    
    @IBOutlet var Navbar: UINavigationBar!
    @IBOutlet var Toolbar: UIToolbar!
    
    @IBAction func addAllergy(_ sender: UIButton) {
        // If add is pressed, append new allergy to allergies array, update UI to show inserted row, and update allergies in scanner settings document
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
    
    @IBAction func resetSettings(_ sender: Any) {
        // Display an alert if reset is pressed to confirm that the user wants to reset their settings to the default
        let alert = UIAlertController(title: "Reset settings?", message: "Resetting your settings to the default will uncheck all diets and delete all allergies and intolerances.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { action in
            
            // If reset is confirmed, update the scanner settings document to its default fields and refresh UI to reflect changes
            self.scannerData.setData(self.defaultSettings)
            self.dietsSelected = [Bool](repeating: false, count: 6)
            self.allergies = [String]()
            self.DietsTableView?.reloadData()
            self.AllergiesTableView?.reloadData()

            }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let IS = ImageSetter()
        
        IS.SetBarImage(Navbar: Navbar)
        IS.SetBarImage(Toolbar: Toolbar)
        
        AddAllergyButton.layer.cornerRadius = 5
        AddAllergyButton.clipsToBounds = true

    AllergiesTextField.contentVerticalAlignment = .center

        DietsTableView?.dataSource = self
        DietsTableView?.delegate = self
        DietsTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "DietCell")
        
        AllergiesTableView?.dataSource = self
        AllergiesTableView?.delegate = self
        AllergiesTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "AllergyCell")
        
        db = Firestore.firestore()
        loadSettings()
    }
    
    func loadSettings() {
        // Get reference to scanner settings document using uid of current user and use fields of that document to populate the diets selected and allergies arrays
        if let userID = Auth.auth().currentUser?.uid {
            scannerData = db.collection("users").document(userID).collection("Settings").document("Scanner")
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let scannerSettings = document.data()
                    for i in 0 ... self.diets.count - 1 {
                        self.dietsSelected[i] = scannerSettings![self.diets[i]] as! Bool
                    }
                    self.allergies = scannerSettings!["Allergies"] as! [String]
                }
                else {
                    self.scannerData.setData(self.defaultSettings) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
                // Reload both table views to reflect the document information stored in the arrays
                self.DietsTableView?.reloadData()
                self.AllergiesTableView?.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.DietsTableView {
            // If the table view being loaded is the diets, reuse the diet cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DietCell")!
            // Use the diets array to fill in the diet label
            cell.textLabel?.text = diets[indexPath.row]
        
            // Use the diets selected array to determine whether to make the switch on or off and watch for changes to that switch
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(dietsSelected[indexPath.row], animated: true)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
            cell.accessoryView = switchView
            return cell
        }
        else {
            // If the table view being loaded is the allergies, reuse the allergy cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllergyCell")!
            // Use the allergies array to fill in the allergy label
            cell.textLabel?.text = allergies[indexPath.row]
            return cell
        }
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        dietsSelected[sender.tag] = sender.isOn;
        // If a switch is changed, update the scanner settings document with the appropriate value for the corresponding diet
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
        // If the user deletes an allergy, remove it from the allergies array, update UI to show deleted row, and update allergies in scanner settings document
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
    
    @IBAction func OnImportButtonPressed(_ sender: Any) {
        VT.ChangeView(FromViewController: self, StoryboardName: "Settings", ViewID: "ImportSettingsView", ViewControllerClass: ImportSettingsViewController.self, PushDirection: .left)
    }
    @IBAction func OnBackButtonPressed(_ sender: Any) {
        VT.ChangeView(FromViewController: self, StoryboardName: "Settings", ViewID: "SettingsView", ViewControllerClass: SettingsViewController.self, PushDirection: .right)
    }
    
}
