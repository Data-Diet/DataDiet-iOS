//
//  ImageSetter.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 11/20/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Foundation

struct ImageSetter {
    
    func SetBarImage(Navbar: UINavigationBar) {
        let currentImage = UIImage(named: "NavbarBackground")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch)
        Navbar.setBackgroundImage(currentImage, for: .default)
    }
    
    func SetBarImage(Toolbar: UIToolbar) {
        let currentImage = UIImage(named: "NavbarBackground")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch)
        Toolbar.setBackgroundImage(currentImage, forToolbarPosition: .any, barMetrics: .default)
    }
    
}

