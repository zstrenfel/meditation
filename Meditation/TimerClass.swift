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
    case primary = "Meditation"
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
    
    private var sounds: [TimerType: AVAudioPlayer?] = [:]
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
        
        configureAudioSession()
        
        loadSound(type: .countdown, sound: timer.countdown_sound!)
        loadSound(type: .primary, sound: timer.primary_sound!)
        loadSound(type: .cooldown, sound: timer.cooldown_sound!)
        loadSound(type: .interval, sound: timer.interval_sound!)
    }
    
    // MARK: - Sounds
    //enables sounds for silent mode
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        }
        catch {
            log.error("could not configure audio session")
        }
    }
    
    func loadSound(type: TimerType, sound: String) {
        guard sound != "none" else {
            sounds[type] = nil
            return
        }
        soundQueue.sync {
            if let sound = NSDataAsset(name: sound) {
                do {
                    let sound = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
                    sounds[type] = sound
                } catch {
                    log.debug("could not find the allocated sound")
                }
            }
        }
    }
    
    func playSound(type: TimerType) {
        guard sounds[type] != nil else {
            log.debug("no sound was loaded for this timer")
            return
        }
        log.debug("playing sound for \(type)")
        sounds[type]!?.play()
    }
    
    // MARK: - Timer
    
    //do I need to accomodate for the base case of the timer value being 0?
    func startTimer() {
        guard timer == nil else {
            log.error("timer is already running")
            return
        }
        
        guard totalTime > 0.0 else {
            log.error("no time added")
            return
        }
        
        paused = false
        completed = false
        active = true
        currentStatus = countdownEnd > 0.0 ? "Countdown" : "Meditation"
        //set absolute start time of the timers
        startTime = CFAbsoluteTimeGetCurrent()
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
        //get the visual timer started
        delegate?.handleTimerChange(value: totalTime)
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
            stopTimer()
            currentStatus = "Completed"
            active = false
            completed = true
            delegate?.handleTimerChange(value: totalTime - currentTime)
            delegate?.handleTimerComplete()
        } else {
            delegate?.handleTimerChange(value: totalTime - currentTime)
        }
        
        
        if currentTime == countdownEnd {
            playSound(type: .countdown)
            currentStatus = "Meditation"
        } else if currentTime == primaryEnd {
            playSound(type: .primary)
            currentStatus = "Cooldown"
        } else if currentTime == totalTime {
            playSound(type: .cooldown)
        } else if interval > 0.0 {
            let intervalTime = currentTime - countdownEnd
            if intervalTime == interval {
                playSound(type: .interval)
            } else if intervalTime > 0 &&
                (intervalTime + countdownEnd) < primaryEnd &&
                intervalRepeat &&
                intervalTime.truncatingRemainder(dividingBy: interval) == 0 {
                playSound(type: .interval)
            }
        }
        
    }
    
    // MARK: - Outside Accessible
    func setTimeCombleted(with time: Double) {
        currentTime = time
        startTime = CFAbsoluteTimeGetCurrent() - currentTime
        paused = false
        completed = false
        active = true
    }
    
    func timeCompleted() -> Double {
        return currentTime
    }
    
    //returns total amount of time remaining
    func timeRemaining() -> Double {
        return totalTime - currentTime
    }
    
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
