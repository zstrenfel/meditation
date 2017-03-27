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
    
    //do i even need the context here? 
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var type: TimerType?
    var timer: MeditationTimer?
    
    var updateParent: ((_ value: Double, _ type: TimerType) -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.isHidden = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var timerPickerView: TimerPickerView = {
        let pickerView = TimerPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    func setupViews() {
        addSubview(timerPickerView)
        timerPickerView.onTimeSelected = handlePickerChange
        
        let horizontalVisibleConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[v0]-32-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": timerPickerView])
        let verticalVisibleConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8@750)-[v0]-(8@750)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": timerPickerView])
        NSLayoutConstraint.activate(horizontalVisibleConstraint)
        NSLayoutConstraint.activate(verticalVisibleConstraint)
    }
    
    func updateTimePickerView() {
        guard timer != nil && type != nil else {
            log.error("timer and/or type is nil, and this function cannot be completed")
            return
        }
        var time = 0.0
        switch self.type! {
        case .countdown:
            time = (timer?.countdown)!
            break
        case .primary:
            time = (timer?.primary)!
            break
        case .cooldown:
            time = (timer?.cooldown)!
            break
        case .interval:
            time = (timer?.interval)!
        }
        
        self.timerPickerView.update(time)
    }
    
    func handlePickerChange(_ hour: Int, _ minute: Int, _ second: Int) {
        let condensedTime = Double(hour * 3600 + minute * 60 + second)
        var toUpdate = ""
        
        switch self.type! {
        case .countdown:
            toUpdate = "countdown"
            break
        case .primary:
            toUpdate = "primary"
            break
        case .cooldown:
            toUpdate = "cooldown"
            break
        case .interval:
            toUpdate = "interval"
        }
        
        if timer != nil {
            //do I need to save this as well?
            timer?.setValue(condensedTime, forKey: toUpdate)
        } else {
            log.error("timer shouldn't ever be nil here")
        }
        
        if let block = updateParent {
            block(condensedTime, type!)
        }
    }
}
