//
//  PickerTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {
    var parent: UITableViewCell?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
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
    
    func setTime(hours: Int, minutes: Int, seconds: Int) {
        print("setting time")
        //add default values if they exist
        timerPickerView.hour = hours
        timerPickerView.minute = minutes
        timerPickerView.second = seconds
    }
    
    func setPickerCallback(_ callback: @escaping (_ hour: Int, _ minute: Int, _ second: Int) -> Void) {
        timerPickerView.onTimeSelected = callback
    }
    
    
    func getTimeValue() -> String {
        return Double(timerPickerView.hour * 3600 + timerPickerView.minute * 60 + timerPickerView.second).timeString
    }

}
