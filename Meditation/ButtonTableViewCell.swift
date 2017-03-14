//
//  ButtonTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/14/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
    }
}
