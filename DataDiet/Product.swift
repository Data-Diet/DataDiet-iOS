//
//  Product.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 6/26/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

class Product {
    
    var title: String
    var URL: String
    var image: UIImage
    
    init(URL: String) {
        self.URL = URL
        self.title = ""
        self.image = UIImage.init()
    }
}
