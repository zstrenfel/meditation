//
//  InputTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/14/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func inputChange(_ sender: UITextField) {
    }
}
