//
//  HistoryTableViewCell.swift
//  DataDiet
//
//  Created by Ashley Cline on 11/26/19.
//  Copyright © 2019 DataDiet. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var ProductTitleLabel: UILabel!
    @IBOutlet weak var ScannedSettingsLabel: UILabel!
    @IBOutlet weak var FoundSettingsLabel: UILabel!
    
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    */
    
    // Use product details to fill in history labels
    func setProductDetails(product: Product) {
        ProductTitleLabel.text = product.title
        ScannedSettingsLabel.text = "Scanned: " + product.dietsScanned.joined(separator: ", ") + (product.dietsScanned.isEmpty ? "" : ", ") + product.allergensScanned.joined(separator: ", ")
        FoundSettingsLabel.text = "Found: " + product.dietsFound.joined(separator: ", ") + (product.dietsScanned.isEmpty ? "" : ", ") + product.allergensFound.joined(separator: ", ")
    }
    
}
