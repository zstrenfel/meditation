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
    
    //Array of timers and their corresponding information
    private var timers: [TimerInfo]
    //Timer that is currently in use
    private var currentTimer: Timer?
    //Index of current timer in use
    private var currentTimerIndex: Int = 0
    
    private var startTime: Double = 0.0
    private var currentTime: Double = 0.0
    
    private var interval: TimerInfo
    
    private var active: Bool = false
    private var paused: Bool = false
    private var completed: Bool = false
    
    private var sounds: [TimerType: AVAudioPlayer] = [:]
    private var soundQueue = DispatchQueue(label: "strenfel.zach.soundQ")
    private var maxPlayTime: DispatchTimeInterval = .seconds(5)
    
    var updateParent: ((_ remaining: Double,_ type: TimerType) -> Void)?
    var onComplete: (() -> Void)?
    
    init(with timer: MeditationTimer) {
        let countdownInfo = TimerInfo(
            time: timer.countdown,
            sound: timer.countdown_sound!,
            type: .countdown,
            shouldRepeat: nil,
            index: 0)
        let primaryInfo = TimerInfo(
            time: timer.primary,
            sound: timer.primary_sound!,
            type: .primary,
            shouldRepeat: nil,
            index: 1)
        let cooldownInfo = TimerInfo(time:
            timer.cooldown,
            sound: timer.cooldown_sound!,
            type: .cooldown,
            shouldRepeat: nil,
            index: 2)
        self.interval = TimerInfo(
            time: timer.interval,
            sound: timer.interval_sound!,
            type: .interval,
            shouldRepeat:
            timer.interval_repeat,
            index: 100)
        
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
    
    // MARK: - Timer
    
    //do I need to accomodate for the base case of the timer value being 0?
    func startTimer() {
        guard currentTimer == nil else {
            log.error("timer is already running")
            return
        }
        paused = false
        completed = false
        active = true
        
        //set absolute start time of the timers
        startTime = CFAbsoluteTimeGetCurrent()
        
        currentTimer = Timer()
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        paused = true
        if let curr = currentTimer {
            curr.invalidate()
            currentTimer = nil
            
            //set difference in start and pause time to be used later when restarting
            startTime = CFAbsoluteTimeGetCurrent() - startTime
        }
    }
    
    func resumeTimer() {
        paused = false
        //start time should be moved back to accomodate the time that has already passed
        startTime = CFAbsoluteTimeGetCurrent() - startTime
        currentTimer = Timer()
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerWrapper.countdown), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let curr = currentTimer {
            curr.invalidate()
            currentTimer = nil
            
            startTime = CFAbsoluteTimeGetCurrent() - startTime
        }
        
        paused = false
        completed = true
        active = false
        self.currentTime = 0.0
        self.currentTimerIndex = 0
        self.startTime = 0.0
    }
    
    @objc func countdown() {
        //if the current timer is expired, make sound and start next timer
        if currentTime >= timers[currentTimerIndex].time - 1 {
            playSound(type: timers[currentTimerIndex].type)
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
    
    func setNextTimer() {
        //if this is the last timer, end
        guard currentTimerIndex < timers.count - 1 else {
            log.debug("Index is out of range")
            pauseTimer()
            completed = true
            
            delegate?.handleTimerComplete()
            return
        }
        
        //else update the currentTimerIndex by one to set the next timer
        currentTimerIndex += 1
    }
    
    // MARK: - Sound
    
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
        sounds[type]!.play()
        soundQueue.asyncAfter(deadline: .now() + maxPlayTime) {
            self.sounds[type]?.stop()
            self.sounds[type]?.currentTime = 0
        }
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
