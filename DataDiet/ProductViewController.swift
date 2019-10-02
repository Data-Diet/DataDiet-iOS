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
    @IBOutlet var productNav: UINavigationBar!
    
    let SegueIdProductJSON = "productJSON"
    
    var product: Product?
    
    //the json file url
    let URL_HEROES = "http://192.168.1.105/json/heroes.php";
    
    //A string array to save all the names
    var nameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        let url = NSURL(string: URL_HEROES)
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                //printing the json in console
                print(jsonObj.value(forKey: "avengers")!)
                
                //getting the avengers tag array from json and converting it to NSArray
                if let heroeArray = jsonObj.value(forKey: "avengers") as? NSArray {
                    //looping through all the elements
                    for heroe in heroeArray{
                        
                        //converting the element to a dictionary
                        if let heroeDict = heroe as? NSDictionary {
                            
                            //getting the name from the dictionary
                            if let name = heroeDict.value(forKey: "name") {
                                
                                //adding the name to the array
                                self.nameArray.append((name as? String)!)
                            }
                            
                        }
                    }
                }
                
                OperationQueue.main.addOperation({
                    //calling another function after fetching the json
                    //it will show the names to label
                })
            }
        }).resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == SegueIdProductJSON {
            product = sender as? Product
            print(product?.URL ?? "")
        }
    }
    
    
}
