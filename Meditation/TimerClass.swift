//
//  TimerClass.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/6/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import XCGLogger

enum TimerType: String {
    case primary = "Meditation Time"
    case countdown = "Countdown"
    case cooldown = "Cooldown"
    case interval = "Interval"
}

struct TimerInfo {
    var time: Double
    var sound: String
    var type: TimerType
}

class TimerWrapper {
    var timers: [TimerInfo]
    var currentIndex: Int = 0
    var currentCountdown: Double = 0.0
    var currentTimer: Timer?
    
    var interval: Double
    var intervalSound: String
    
    var updateParent: ((_ remaining: Double,_ type: TimerType, _ completed: Bool) -> Void)?
    
    var paused: Bool = true
    var completed: Bool = true
    
    init(with timers: [TimerInfo], interval: Double = 0.0, intervalSound: String = "") {
        self.timers = timers.filter { $0.time > 0.0 }
        self.interval = interval
        self.intervalSound = intervalSound
        setNextTimer()
    }
    
    func setNextTimer() -> Bool {
        guard currentIndex < timers.count else {
            log.debug("Index is out of range")
            stopTimer(clear: true)
            return false
        }
        currentCountdown = timers[currentIndex].time
        return true
    }
    
    //do I need to accomodate for the base case of the timer value being 0?
    func startTimer() {
        paused = false
        completed = false
        currentTimer = Timer()
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        guard currentCountdown > 0 else {
//            makeSound(sound: timers[currentIndex].sound)
            currentIndex += 1
            if setNextTimer() {
                startTimer()
            }
            return
        }
        currentCountdown = currentCountdown - 1
        //alert user on correct intervals
        if currentCountdown.truncatingRemainder(dividingBy: interval) == 0 {
//            makeSound(sound: intervalSound)
        }
        if let block = updateParent {
            block(currentCountdown, timers[currentIndex].type, false)
        }
    }
    
    func stopTimer(clear: Bool) {
        paused = true
        if currentTimer != nil {
            currentTimer!.invalidate()
        }
        
        //if the session is ended, reset the timer
        if clear {
            completed = true
            self.currentCountdown = 0.0
            self.currentIndex = 0
            currentTimer = nil
            //update parent that timer is finished/reset
            if let block = updateParent {
                block(currentCountdown, timers[currentIndex].type, clear)
            }
        }
    }
    
    func makeSound(sound: String) {
        log.debug("making sound: " + sound)
    }
    
    func isPaused() -> Bool {
        return paused
    }
    
    func isCompleted() -> Bool {
        return completed
    }
}
