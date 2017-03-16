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
    @IBOutlet weak var inputField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var type: TimerType?
    var timer: MeditationTimer? = nil {
        didSet {
            updateInputFieldValue(timer: timer!)
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
    
    func updateInputFieldValue(timer: MeditationTimer) {
        if let name = timer.name {
            self.inputField.text = name
        }
    }
    
    //MARK: - Actions

    @IBAction func inputChange(_ sender: UITextField) {
        guard timer != nil else {
            log.error("timer is nil, cannot update")
            return
        }
        timer!.setValue(sender.text, forKey: "name")
    }
}
