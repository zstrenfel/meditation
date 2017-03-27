//
//  ToggleTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/23/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    
    var updateParent: ((_ value: Bool, _ label: String) -> Void)?
    var toggleValue: Bool = false {
        didSet {
            toggle.isOn = toggleValue
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func toggleValue(_ sender: UISwitch) {
        if let block = updateParent {
            block(sender.isOn, optionLabel.text!)
        }
    }
}
