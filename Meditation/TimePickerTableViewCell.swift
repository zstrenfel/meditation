//
//  TimePickerTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit
import XCGLogger

class TimePickerTableViewCell: UITableViewCell {
    
    var type: TimerType?
    var updateParent: ((_ value: Double, _ type: TimerType) -> Void)?
    var value: Double = 0.0 {
        didSet {
            log.debug(self.value)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.isHidden = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //must be a lazy variable in order to use self inside of the closure
    lazy var timerPickerView: TimerPickerView = { [unowned self] in
        let pickerView = TimerPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.update(self.value)
        return pickerView
    }()
    
    func setupViews() {
        addSubview(timerPickerView)
        timerPickerView.onTimeSelected = handlePickerChange
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[v0]-32-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": timerPickerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": timerPickerView]))
    }
    
    func handlePickerChange(_ hour: Int, _ minute: Int, _ second: Int) {
        let condensedTime = Double(hour * 3600 + minute * 60 + second)
        if let block = updateParent {
            block(condensedTime, type!)
        }
    }
}
