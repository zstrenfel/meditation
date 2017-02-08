//
//  TimerClass.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/6/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

enum TimerType: String {
    case primary = "Meditation Time"
    case countdown = "Countdown"
    case cooldown = "Cooldown"
    case interval = "Interval"
}

class TimerClass {
    var time: Double
    var remaining: Double
    var alert: String?
    var timerType: TimerType
    
    var paused: Bool = false
    var completed: Bool = true
    
    var updateParent: ((_ remaining: Double,_ type: TimerType) -> Void)?

    
    weak var timer: Timer?
    
    init(with time: Double, alert: String? = nil, type: TimerType, callback: @escaping (_ remaining: Double,_ type: TimerType) -> Void ) {
        self.time = time
        self.remaining = time
        self.alert = alert
        self.timerType = type
        self.updateParent = callback
    }
    
    func update(with time: Double) {
        guard completed == true else {
            print("canot update timer while it is running")
            return
        }
        self.time = time
        self.remaining = self.time
    }
    
    func startTimer() {
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerClass.countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        guard remaining > 0 else {
            stopTime(clear: false) //don't end session unless the user wants to
            return
        }
        remaining = remaining - 1
        
        if let block = updateParent {
            block(remaining, timerType)
        }
    }
    
    func stopTime(clear: Bool) {
        if timer != nil {
            timer!.invalidate()
        }
        
        //if the session is ended, reset the timer
        if clear {
            self.remaining = self.time
            timer = nil
            if let block = updateParent {
                block(remaining, timerType)
            }
        }
    }
    
    func togglePause() {
        paused = !paused
    }
    
    func isPaused() -> Bool {
        return paused
    }
    
    func toggleCompleted() {
        completed = !completed
    }
    
    func isCompleted() -> Bool {
        return completed
    }
}
