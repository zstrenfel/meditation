//
//  TimerPickerView.swift
//  Meditation
//
//  Created by Zach Strenfel on 1/18/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class TimerPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var hours: [Int]!
    var minutes: [Int]!
    var seconds: [Int]!
    
    var onTimeSelected: ((_ hour: Int, _ minute: Int, _ second: Int) -> Void)?
    
    var hour: Int = 0 {
        didSet {
            selectRow(hour, inComponent: 0, animated: false)
        }
    }
    
    var minute: Int = 10 {
        didSet {
            selectRow(minute, inComponent: 1, animated: false)
        }
    }
    
    var second: Int = 0 {
        didSet {
            selectRow(second, inComponent: 2, animated: false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        var hours: [Int] = []
        if hours.count == 0 {
            for num in 0...12 {
                hours.append(num)
            }
        }
        self.hours = hours
        
        var minutes: [Int] = []
        if minutes.count == 0 {
            for num in 0...59 {
                minutes.append(num)
            }
        }
        self.minutes = minutes
        
        var seconds: [Int] = []
        if seconds.count == 0 {
            for num in 0...59 {
                seconds.append(num)
            }
        }
        self.seconds = seconds
        
        self.delegate = self
        self.dataSource = self
        
        let label: UILabel = {
            let label = UILabel()
            label.text = "Hours"
            return label
        }()
        
    }
    
    // MARK: UIPickerView Data Source / Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(self.hours[row])"
        case 1:
            return "\(self.minutes[row])"
        case 2:
            return "\(seconds[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        case 2:
            return seconds.count
        default:
            return 0
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let hour = self.selectedRow(inComponent: 0)
        let minute = self.selectedRow(inComponent: 1)
        let second = self.selectedRow(inComponent: 2)
        
        if let block = onTimeSelected {
            block(hour, minute, second)
        }
        
        self.hour = hour
        self.minute = minute
        self.second = second
    }
}
