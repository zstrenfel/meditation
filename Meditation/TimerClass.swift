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
    
    weak var delegate: TimerDelegate?
    
    var timer: Timer? = nil
    var meditationTimer: MeditationTimer
    
    private var totalTime: Double = 0.0
    private var countdownEnd: Double = 0.0
    private var primaryEnd: Double = 0.0
    
    private var startTime: Double = 0.0
    private var currentTime: Double = 0.0
    private var currentStatus: String = "Countdown" {
        didSet {
            delegate?.handleTimerChange(value: currentStatus)
        }
    }
    
    private var interval: Double = 0.0
    private var intervalRepeat: Bool = false
    
    private var active: Bool = false
    private var paused: Bool = false
    private var completed: Bool = false
    
    private var sounds: [TimerType: AVAudioPlayer] = [:]
    private var soundQueue = DispatchQueue(label: "strenfel.zach.soundQ")
    private var maxPlayTime: DispatchTimeInterval = .seconds(5)
    
    var updateParent: ((_ remaining: Double,_ type: TimerType) -> Void)?
    var onComplete: (() -> Void)?
    
    init(with timer: MeditationTimer) {
        self.meditationTimer = timer
        self.totalTime = timer.countdown + timer.primary + timer.cooldown
        self.countdownEnd = timer.countdown
        self.primaryEnd = timer.countdown + timer.primary
        self.interval = timer.interval
        self.intervalRepeat = timer.interval_repeat
        
        loadSound(type: .countdown, path: timer.countdown_sound!)
        loadSound(type: .primary, path: timer.primary_sound!)
        loadSound(type: .cooldown, path: timer.cooldown_sound!)
        loadSound(type: .interval, path: timer.interval_sound!)
    }
    
    // MARK: - Sounds
    
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
        guard sounds[type] != nil else {
            log.debug("no sound was loaded for this timer")
            return
        }
        log.debug("playing sound for \(type)")
        sounds[type]!.play()
        soundQueue.asyncAfter(deadline: .now() + maxPlayTime) {
            self.sounds[type]?.stop()
            self.sounds[type]?.currentTime = 0
        }
    }
    
    // MARK: - Timer
    
    //do I need to accomodate for the base case of the timer value being 0?
    func startTimer() {
        guard timer == nil else {
            log.error("timer is already running")
            return
        }
        paused = false
        completed = false
        active = true
        currentStatus = "Countdown"
        //set absolute start time of the timers
        startTime = CFAbsoluteTimeGetCurrent()
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        paused = true
        if let t = timer {
            t.invalidate()
            timer = nil
            
            //set difference in start and pause time to be used later when restarting
            startTime = CFAbsoluteTimeGetCurrent() - startTime
        }
    }
    
    func resumeTimer() {
        paused = false
        //start time should be moved back to accomodate the time that has already passed
        startTime = CFAbsoluteTimeGetCurrent() - startTime
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    func clearTimer() {
        stopTimer()
        
        paused = false
        completed = true
        active = false
        self.currentTime = 0.0
        self.startTime = 0.0
    }
    
    @objc func countdown() {
        currentTime = round(CFAbsoluteTimeGetCurrent() - startTime)
        if currentTime >= totalTime {
            currentStatus = "Completed"
             stopTimer()
            if meditationTimer.cooldown > 0.0 {
                playSound(type: .cooldown)
            } else {
                playSound(type: .primary)
            }
        } else {
            if currentTime == countdownEnd {
                playSound(type: .countdown)
                currentStatus = "Meditation"
            } else if currentTime == primaryEnd {
                playSound(type: .primary)
                currentStatus = "Cooldown"
            } else if interval > 0.0 {
                let intervalTime = currentTime - countdownEnd
                if intervalTime == interval {
                    playSound(type: .interval)
                } else if intervalTime > 0 &&
                    intervalRepeat &&
                    intervalTime.truncatingRemainder(dividingBy: interval) == 0 {
                    playSound(type: .interval)
                }
            }
        }
        
        delegate?.handleTimerChange(value: totalTime - currentTime)
    }
    
    // MARK: - Outside Accessible
    
    //Function that returns if the timer is paused
    func isPaused() -> Bool {
        return paused
    }
    
    //Fn that returns whether the timer has completed
    func isCompleted() -> Bool {
        return completed
    }
    
    //Fn that returns whether the timer is active (has begun)
    func isActive() -> Bool {
        return active
    }
}
