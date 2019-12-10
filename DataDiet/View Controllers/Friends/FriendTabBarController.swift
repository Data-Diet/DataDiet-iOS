//
//  FriendTabBarController.swift
//  DataDiet
//
//  Created by Jeremy Manalo on 12/9/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit
import Hero

class FriendTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        // Do any additional setup after loading the view.
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

extension FriendTabBarController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false // Make sure you want this as false
        }

        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
