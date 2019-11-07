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

class ScannerSettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let diets = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var allergies = [String]()

    
    @IBOutlet weak var DietsTableView: UITableView!
    @IBOutlet weak var AllergiesTextField: UITextField!
    @IBOutlet weak var AllergiesTableView: UITableView!
    
    @IBAction func addAllergy(_ sender: UIButton) {
        allergies.append(AllergiesTextField.text!)
        let indexPath = IndexPath(row: allergies.count - 1, section: 0)
        AllergiesTableView.beginUpdates()
        AllergiesTableView.insertRows(at: [indexPath], with: .automatic)
        AllergiesTableView.endUpdates()
        AllergiesTextField.text = ""
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DietsTableView.dataSource = self
        DietsTableView.delegate = self
        DietsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DietCell")
        
        AllergiesTableView.dataSource = self
        AllergiesTableView.delegate = self
        AllergiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AllergyCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.DietsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DietCell")!
            cell.textLabel?.text = diets[indexPath.row]
        
            let swicthView = UISwitch(frame: .zero)
            swicthView.setOn(false, animated: true)
            swicthView.tag = indexPath.row
            swicthView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
            cell.accessoryView = swicthView
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllergyCell")!
            cell.textLabel?.text = allergies[indexPath.row]
            return cell
        }
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        print("Table switch changed on \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
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
               print(allergies)
        }
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
