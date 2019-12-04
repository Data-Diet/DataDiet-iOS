//
//  PendingCell.swift
//  DataDiet
//
//  Created by Eric Zamora on 11/30/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

protocol PendingCellDelegate {
    func didTapAccept(UID: String, cell: UITableViewCell)
}

class PendingCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    var delegate: PendingCellDelegate?
    var userItem: User!
    
    // set
    func setUser(user: User){
        userItem = user
        profileImageView.image = user.image
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
    }
    
    @IBAction func acceptTapped(_ sender: UIView) {
        delegate?.didTapAccept(UID: userItem.UID, cell: self)
    }
}
