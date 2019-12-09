//
//  USDA_API.swift
//  USDA_API
//
//  Created by Kenneth Mai on 10/29/19.
//  Copyright © 2019 Kenneth Mai. All rights reserved.
//

/* How to make a USDA request for ingredients ****************************

 Input: Barcode Number, Output: Ingredients Array
 
 Examaple Call:
 
 let data = USDARequest()
 data.getIngredients(barcodeNumber: "00028400165440") { (ingredientsArray) in
     //Can access all the ingredients in here if barcode is specified
     for element in ingredientsArray { //Testing
         print(element)
     }
 }
 
**************************************************************************/

import Foundation

struct OpenFoodFactsRequest{
     
    let API_KEY = "aGdpm2mtlYcffnTgvTbh8axBPC9wdn8Z4tF0HvJ5"
    
    func getImage(barcodeNumber: String, completionHandler: @escaping ((Array<String>) -> Void)) {
         var params:[String: Any]?
         let session = URLSession.shared
         let url = "https://api.nal.usda.gov/fdc/v1/search?api_key=\(API_KEY)"
         let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
         request.httpMethod = "POST"
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         params = ["generalSearchInput":"\(barcodeNumber)"]
        
         do {
             request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            
             let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: { (data, response, error) in
                guard let data = data else { return }
                
                if let ingredientsString = String(data: data, encoding: .utf8) {
                    let ingredients = self.formatIngredients(ingredientsList: ingredientsString)
                    completionHandler(ingredients)
                }
                print()
                print("USDA product response:")
                print(String(data: data, encoding: .utf8))
                print()
             } )
             task.resume()
         } catch {
             print ("Error")
         }
     }
    
    func getTitle(barcodeNumber: String, completionHandler: @escaping ((String) -> Void)) {
        var params:[String: Any]?
        let session = URLSession.shared
        let url = "https://api.nal.usda.gov/fdc/v1/search?api_key=\(API_KEY)"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        params = ["generalSearchInput":"\(barcodeNumber)"]
       
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
           
            let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: { (data, response, error) in
                guard let data = data else { return }
                
                var productTitle = String()
                
                if let BrandString = String(data: data, encoding: .utf8) {
                let title = String(BrandString.substring(from: "brandOwner" + "\"" + ":" + "\"", to: "\"") ?? "")
                    productTitle += title
                }
            
                if let NameString = String(data: data, encoding: .utf8) {
                 let title = String(NameString.substring(from: "description" + "\"" + ":" + "\"", to: "\"") ?? "")
                    productTitle += ": " + title
                }
                completionHandler(productTitle)
                print()
                print("USDA product response:")
                print(String(data: data, encoding: .utf8))
                print()
            } )
            task.resume()
        } catch {
            print ("Error")
        }
    }
    
    //Function used to format ingredients list into an array
    func formatIngredients(ingredientsList: String) -> Array<String> {
        let ingredients = ingredientsList.substring(from: "ingredients" + "\"" + ":" + "\"", to: ".");
        
        guard var rmChars = ingredients?.replacingOccurrences(of: "[\\[\\]\\(\\)]", with: "", options: .regularExpression, range: nil) else {
                print("Barcode was not found in USDA Database")
                return [String]()
            }
        
        rmChars = rmChars.replacingOccurrences(of: "Made from ", with: "")
        rmChars = rmChars.replacingOccurrences(of: "and ", with: "")
        rmChars = rmChars.replacingOccurrences(of: "and/or ", with: "")
        return rmChars.components(separatedBy: ", ")
    }
}
