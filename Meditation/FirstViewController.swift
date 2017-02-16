//
//  FirstViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit
import Dollar
import Cent
import XCGLogger


class FirstViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var cooldownLabel: UILabel!
    
    var timers: [TimerType: TimerInfo] = [:]
    var sessionTimers: TimerWrapper?
    
    var currentTimerIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if timers.values.count == 0 {
            log.debug("no current values for the timers, creating defaults now")
            timers[.primary] = TimerInfo(time: 0.0, sound: "Bells.wav", type: .primary, shouldRepeat: nil)
            timers[.countdown] = TimerInfo(time: 0.0, sound: "Bells.wav", type: .countdown, shouldRepeat: nil)
            timers[.cooldown] = TimerInfo(time: 0.0, sound: "Bells.wav", type: .cooldown, shouldRepeat: nil)
            timers[.interval] = TimerInfo(time: 0.0, sound: "Bells.wav", type: .interval, shouldRepeat: false)
        }
        
        //update labels with the appropriate time
        //redundent????
        timerLabel.text = timers[.primary]?.time.timeString
        countdownLabel.text = timers[.countdown]?.time.timeString
        cooldownLabel.text = timers[.cooldown]?.time.timeString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTimerLabels(_ value: Double, _ type: TimerType) {
        switch type {
        case .countdown:
            countdownLabel.text = value.timeString
        case .primary:
            timerLabel.text = value.timeString
        case .cooldown:
            cooldownLabel.text = value.timeString
        case .interval:
            //do nothing
            break
        }
    }
    
    func resetTimerLabels() {
        //timer is completed, reset all labels
        countdownLabel.text = timers[.countdown]?.time.timeString
        timerLabel.text = timers[.primary]?.time.timeString
        cooldownLabel.text = timers[.cooldown]?.time.timeString
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        _startTimer()
    }
    
    func _startTimer() {
        var timers = Array(self.timers.values)
        timers = timers.filter { $0.type != .interval }
        sessionTimers = TimerWrapper(with: timers, interval: self.timers[.interval]!)
        sessionTimers?.updateParent = updateTimerLabels
        sessionTimers?.onComplete = onComplete
        sessionTimers?.startTimer()
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        guard sessionTimers != nil else {
            log.debug("no timers running so cannot stop them")
            return
        }
        
        if (sessionTimers?.isPaused())! {
            sessionTimers?.stopTimer(clear: true)
            stopButton.setTitle("Pause", for: .normal)
            resetTimerLabels()
        } else {
            sessionTimers?.stopTimer(clear: false)
            stopButton.setTitle("Reset", for: .normal)
        }
    }
    
    func onComplete() {
        stopButton.setTitle("Reset", for: .normal)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else {
            //no work to be done here
            return
        }
        switch segue.identifier! {
        case "showEditModal":
//            log.debug(segue.destination)
            let navigationController = segue.destination as! UINavigationController
            let targetVC = navigationController.topViewController as! EditModalViewController
            targetVC.timers = self.timers
            targetVC.updateParent = updateTimerLabels
            break
        default:
            //do nothing
            break
        }
    }
    
    //callback for the modal to call on close
    func updateFromModal(_ timers: [TimerType: TimerInfo]) {
        self.timers = timers
        let timerValues = Array(timers.values)
        for timer in timerValues {
            updateTimerLabels(timer.time, timer.type)
        }
    }
}

