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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timer: MeditationTimer? = nil
    var sessionTimer: TimerWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard timer != nil else {
            log.error("timer is not set and this shouldn't happen")
            return
        }
        
        setTimerLabels()
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
    
    func updateTimer(_ timer: MeditationTimer) {
        self.timer = timer
        setTimerLabels()
    }
    
    func setTimerLabels() {
        countdownLabel.text = self.timer?.countdown.timeString
        timerLabel.text = self.timer?.primary.timeString
        cooldownLabel.text = self.timer?.cooldown.timeString
    }
    
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        _startTimer()
    }
    
    func _startTimer() {
        if sessionTimer == nil {
            sessionTimer = TimerWrapper(with: timer!)
            sessionTimer?.updateParent = updateTimerLabels
            sessionTimer?.onComplete = onComplete
        }
        sessionTimer?.startTimer()
        stopButton.setTitle("Pause", for: .normal)
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        _stopTimer()
    }
    
    func _stopTimer() {
        guard sessionTimer != nil else {
            log.debug("no timers running so cannot stop them")
            return
        }
        if (sessionTimer?.isPaused())! {
            sessionTimer?.stopTimer(clear: true)
            stopButton.setTitle("Pause", for: .normal)
            setTimerLabels()
        } else {
            sessionTimer?.stopTimer(clear: false)
            stopButton.setTitle("Reset", for: .normal)
        }
    }
    
    func onComplete() {
        stopButton.setTitle("Reset", for: .normal)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //stop timer if it is running
        _stopTimer()
        
        switch segue.identifier! {
        case "showEditModal":
            let navigationController = segue.destination as! UINavigationController
            let targetVC = navigationController.topViewController as! EditModalViewController
            targetVC.timer = self.timer
            targetVC.onDismiss = updateTimer
            break
        default:
            break
        }
    }
}

