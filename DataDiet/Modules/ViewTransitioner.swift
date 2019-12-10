//
//  ViewTransitioner.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 12/9/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Foundation
import Hero

struct ViewTransitioner{
    
    func ChangeView<T>(FromViewController: UIViewController, StoryboardName: String, ViewID: String, ViewControllerClass: T.Type, PushDirection: HeroDefaultAnimationType.Direction) {

        let VC = UIStoryboard(name: StoryboardName, bundle: nil).instantiateViewController(withIdentifier: ViewID) as? T
        
        (VC as! UIViewController).hero.modalAnimationType = .push(direction: PushDirection)
        
        FromViewController.present(VC as! UIViewController, animated: true, completion: nil)
    }
}
