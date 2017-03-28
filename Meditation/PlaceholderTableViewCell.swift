//
//  PlaceholderTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/27/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class PlaceholderTableViewCell: UITableViewCell {
    
    var handleNewMeditation: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func createNewMeditation(_ sender: UIButton) {
        if let block = handleNewMeditation {
            block()
        }
    }
}
