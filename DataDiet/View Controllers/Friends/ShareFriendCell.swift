//
//  FriendCell.swift
//  DataDiet
//
//  Created by Eric Zamora on 11/26/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

class ShareFriendCell: UITableViewCell {
    
    //
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    func setShareUser(user: ShareUser){
        profileImageView.image = user.image
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        fullNameLabel.text = user.fullname
        usernameLabel.text = user.username
    }
}
