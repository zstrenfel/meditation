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
    
    //should be passed in
    var timer: MeditationTimer? = nil
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    var timers: [TimerType: TimerInfo] = [:]
    var sessionTimers: TimerWrapper?
    
    var currentTimerIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard timer != nil else {
            log.error("timer is not set and this shouldn't happen")
            return
        }
        
        //update labels with the appropriate time
        //redundent????
        timerLabel.text = timer?.primary.timeString
        countdownLabel.text = timer?.countdown.timeString
        cooldownLabel.text = timer?.cooldown.timeString
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
        if sessionTimers == nil {
            sessionTimers = TimerWrapper(with: timer!)
            sessionTimers?.updateParent = updateTimerLabels
            sessionTimers?.onComplete = onComplete
        }
        sessionTimers?.startTimer()
        stopButton.setTitle("Pause", for: .normal)
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
            targetVC.timer = self.timer
            targetVC.updateParent = updateTimer
            break
        default:
            //do nothing
            break
        }
    }
    
    func updateTimer(_ type: TimerType, _ info: TimerInfo) {
        log.debug(type)
        self.timers[type] = info
        updateTimerLabels(info.time, type)
    }
}

