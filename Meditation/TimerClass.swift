//
//  TimerClass.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/6/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import XCGLogger
import AVFoundation

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
    var shouldRepeat: Bool?
    var index: Int
}

class TimerWrapper {
    var timers: [TimerInfo]
    var currentIndex: Int = 0
    var currentTimer: Timer?
    
    var startTime: Double = 0.0
    var currentTime: Double = 0.0
    
    var interval: TimerInfo
    
    var updateParent: ((_ remaining: Double,_ type: TimerType) -> Void)?
    var onComplete: (() -> Void)?
    
    var paused: Bool = false
    var completed: Bool = false
    
    var sounds: [TimerType: AVAudioPlayer] = [:]
    var soundQueue = DispatchQueue(label: "strenfel.zach.soundQ")
    
    init(with timer: MeditationTimer) {
        let countdownInfo = TimerInfo(time: timer.countdown, sound: timer.countdown_sound!, type: .countdown, shouldRepeat: nil, index: 0)
        let primaryInfo = TimerInfo(time: timer.primary, sound: timer.primary_sound!, type: .primary, shouldRepeat: nil, index: 1)
        let cooldownInfo = TimerInfo(time: timer.cooldown, sound: timer.cooldown_sound!, type: .cooldown, shouldRepeat: nil, index: 2)
        
        self.interval = TimerInfo(time: timer.interval, sound: timer.interval_sound!, type: .interval, shouldRepeat: timer.interval_repeat, index: 100)
        
        self.timers = [countdownInfo, primaryInfo, cooldownInfo]
        self.timers = timers.filter { $0.time > 0.0 }
        self.timers = self.timers.sorted { $0.index < $1.index }
        
        //load the appropriate sounds
        for timer in timers {
            loadSound(type: timer.type, path: timer.sound)
        }
        //load interval sound
        loadSound(type: .interval, path: timer.interval_sound!)
    }
    
    func setNextTimer() {
        guard currentIndex < timers.count - 1 else {
            log.debug("Index is out of range")
            stopTimer(clear: false)
            completed = true
            //let parent know that the timer finished
            if let block = onComplete {
                block()
            }
            return
        }
        currentIndex += 1
    }
    
    //do I need to accomodate for the base case of the timer value being 0?
    func startTimer() {
        startTime = CFAbsoluteTimeGetCurrent()
        if currentTimer != nil {
            currentTimer?.invalidate()
        }
        paused = false
        completed = false
        currentTimer = Timer()
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    func stopTimer(clear: Bool) {
        paused = true
        if currentTimer != nil {
            currentTimer!.invalidate()
            startTime = CFAbsoluteTimeGetCurrent() - startTime
        }
        
        //if the session is ended, reset the timer
        if clear {
            completed = true
            self.currentTime = 0.0
            self.currentIndex = 0
            self.startTime = 0.0
            currentTimer = nil
            //update parent that timer is finished/reset
            if let block = updateParent {
                block(timers[currentIndex].time - currentTime, timers[currentIndex].type)
            }
        }
    }
    
    @objc func countdown() {
        //if the current timer is expired, make sound and start next timer
        if currentTime >= timers[currentIndex].time - 1 {
            playSound(type: timers[currentIndex].type)
            currentTime = 0.0
            setNextTimer()
        } else {
            currentTime = round(CFAbsoluteTimeGetCurrent() - startTime)
            //alert user on correct intervals
            if currentTime.truncatingRemainder(dividingBy: interval.time) == 0 {
                playSound(type: .interval)
            }
        }
    }
    
    
    func loadSound(type: TimerType, path: String) {
        soundQueue.sync {
            let path = Bundle.main.path(forResource: path, ofType: nil)
            let url = URL(fileURLWithPath: path!)
            do {
                let sound = try AVAudioPlayer(contentsOf: url)
                sounds[type] = sound
            } catch {
                log.debug("could not find the allocated sound")
            }
        }
    }
    
    func playSound(type: TimerType) {
        log.debug("making sound for \(type)")
        //should I stop all sounds here? 
        guard sounds[type] != nil else {
            log.debug("no sound was loaded for this timer")
            return
        }
        sounds[type]!.play()
        let playTime: DispatchTimeInterval = .seconds(5)
        soundQueue.asyncAfter(deadline: .now() + playTime) {
            self.sounds[type]?.stop()
            self.sounds[type]?.currentTime = 0
        }
    }
    
    func isPaused() -> Bool {
        return paused
    }
    
    func isCompleted() -> Bool {
        return completed
    }
}
