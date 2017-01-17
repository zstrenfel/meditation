//
//  IntExtension.swift
//  Meditation
//
//  Created by Zach Strenfel on 1/17/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import Foundation

extension Double {
    var hours: Double {
        let hours = floor(self / 3600)
        guard hours > 0 else {
            return 0
        }
        return hours
    }
    
    var minutes: Double {
        let minutesRemaining = self - (self.hours * 3600)
        return floor(minutesRemaining / 60)
    }
    
    var seconds: Double {
        return self - (self.hours * 3600) - (self.minutes * 60)
    }
    
    func toInt() -> Int {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return 0
        }
    }
    
    var timeFormat: String {
        guard self > 0 else {
            return "00"
        }
        let intRepresentation = self.toInt()
        return String(format: "%02d", intRepresentation)
    }
    
    var timeString: String {
        let hours = self.hours.timeFormat
        let minutes = self.minutes.timeFormat
        let seconds = self.seconds.timeFormat
        return hours + ":" + minutes + ":" + seconds
    }
}
