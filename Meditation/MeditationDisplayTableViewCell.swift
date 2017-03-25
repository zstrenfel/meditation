//
//  MeditationDisplayTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/16/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class MeditationDisplayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roundView: RoundView!

    var timer: MeditationTimer? {
        didSet {
            log.debug(self.timer?.color)
            roundView.fillColor =  UIColor(hexString: (timer?.color)!)
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

}
