import UIKit

class AllergiesSettingsController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AllergiesListView: UITableView!
    @IBOutlet weak var AllergiesTextAddField: UITextField!
    @IBAction func addAllergy(_ sender: Any) {
        insertNewAllergy()
    }
    
    /*Can refer to this array when finding alergies.
      constantly updates when item is added or deleted. */
    var allergies = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AllergiesListView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllergyCell")!
        cell.textLabel?.text = allergies[indexPath.row]
        print(allergies)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allergies.count)
        return allergies.count
    }
    
    func insertNewAllergy() {
        allergies.append(AllergiesTextAddField.text!)
        let indexPath = IndexPath(row: allergies.count - 1, section: 0)
        AllergiesListView.beginUpdates()
        AllergiesListView.insertRows(at: [indexPath], with: .automatic)
        AllergiesListView.endUpdates()
        AllergiesTextAddField.text = ""
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            allergies.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            print(allergies)
        }
    }
    
}

