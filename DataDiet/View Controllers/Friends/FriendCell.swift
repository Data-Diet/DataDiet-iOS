//
//  FriendCell.swift
//  DataDiet
//
//  Created by Eric Zamora on 11/26/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

protocol FriendCellDelegate {
    func didTapAdd(UID: String)
}

class FriendCell: UITableViewCell {
    
    // 
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var delegate: FriendCellDelegate?
    var userItem: User!
    
    
    func setUser(user: User){
        userItem = user
        profileImageView.image = user.image
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        fullNameLabel.text = user.fullname
        usernameLabel.text = user.username
        addButton.layer.cornerRadius = 7
        addButton.clipsToBounds = true
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.didTapAdd(UID: userItem.UID)
    }
    
}
