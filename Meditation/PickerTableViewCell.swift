//
//  PickerTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {
    var hours: Int = 0
    var seconds: Int = 24
    var minutes: Int = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let timerPickerView: TimerPickerView = {
        let pickerView = TimerPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    func setupViews() {
        addSubview(timerPickerView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[v0]-32-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": timerPickerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": timerPickerView]))
    }
    
    func setTime() {
        //add default values if they exist
        timerPickerView.hour = self.hours
        timerPickerView.minute = self.minutes
        timerPickerView.second = self.seconds
    }

}
