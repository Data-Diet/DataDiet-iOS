//  ViewController.swift
//  SwiftJSONTutorial
//
//  Created by Belal Khan on 08/02/17.
//  Copyright © 2017 Belal Khan. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var Navbar: UINavigationBar!
    
    let SegueIdProductJSON = "productJSON"
    
    var product: Product?
    
    var productBarcode = ""
    
    //the json file url
    let URL_HEROES = "http://192.168.1.105/json/heroes.php";
    
    //A string array to save all the names
    var nameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let IS = ImageSetter()
        
        IS.SetBarImage(Navbar: Navbar)
        
        print("productBarcode: " + self.productBarcode)
        
        //calling the function that will fetch the json
        getJsonFromUrl();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this function is fetching the json from URL
    func getJsonFromUrl(){
        //creating a NSURL
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == SegueIdProductJSON {
            product = sender as? Product
            print(product?.URL ?? "")
        }
    }
    
    
}
