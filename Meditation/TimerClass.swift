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
    var currentTimer: Timer?
    
    var currentTime: Double = 0.0
    
    var interval: Double
    var intervalSound: String
    
    var updateParent: ((_ remaining: Double,_ type: TimerType) -> Void)?
    
    var paused: Bool = true
    var completed: Bool = true
    
    init(with timers: [TimerInfo], interval: Double = 0.0, intervalSound: String = "") {
        self.timers = timers.filter { $0.time > 0.0 }
        self.interval = interval
        self.intervalSound = intervalSound
    }
    
    func setNextTimer() {
        guard currentIndex < timers.count - 1 else {
            log.debug("Index is out of range")
            stopTimer(clear: false)
            completed = true
            return
        }
        currentIndex += 1
    }
    
    //do I need to accomodate for the base case of the timer value being 0?
    func startTimer() {
        if currentTimer != nil {
            currentTimer?.invalidate()
        }
        paused = false
        completed = false
        currentTimer = Timer()
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        if currentTime >= timers[currentIndex].time {
            makeSound(sound: timers[currentIndex].sound)
            currentTime = 1.0
            setNextTimer()
        } else {
            currentTime += 1
            //alert user on correct intervals
            if currentTime.truncatingRemainder(dividingBy: interval) == 0 {
                makeSound(sound: intervalSound)
            }
        }
        if !completed {
            if let block = updateParent {
                block(timers[currentIndex].time - currentTime, timers[currentIndex].type)
            }
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
            self.currentTime = 0.0
            self.currentIndex = 0
            currentTimer = nil
            //update parent that timer is finished/reset
            if let block = updateParent {
                block(timers[currentIndex].time - currentTime, timers[currentIndex].type)
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
