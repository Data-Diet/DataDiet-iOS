//
//  ScanSettingsViewController.swift
//  DataDiet
//
//  Created by Kenneth Mai on 10/20/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

class ScanSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Diets: UITableView!
    
    let options = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Diets"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = options[indexPath.row]
        
        //switch
        let swicthView = UISwitch(frame: .zero)
        swicthView.setOn(false, animated: true)
        swicthView.tag = indexPath.row
        swicthView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = swicthView
        return cell
    }

   //Use this function to get preferences that were switch on.
   //Access position through sender.tag
   //Access switch value through sender.isOn
   @objc func switchChanged(_ sender: UISwitch!) {
        print("Table switch changed on \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
    }
}
