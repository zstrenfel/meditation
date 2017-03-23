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
    
    @IBOutlet weak var visualTimer: VisualTimer!
    
    //should be passed in
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timer: MeditationTimer? = nil {
        didSet {
            if timer != nil {
                log.debug(self.timer!)
            }
        }
    }
    var sessionTimer: TimerWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard timer != nil else {
            log.error("timer is not set and this shouldn't happen")
            return
        }
        stopButton.isEnabled = false
        visualTimer.updateTimer(with: self.timer!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if sessionTimer != nil {
            _stopTimer(clear: true)
            visualTimer.clearAnimations()
        }
    }
    
    func updateTimer(_ timer: MeditationTimer?) {
        guard timer != nil else {
            _ = navigationController?.popViewController(animated: true)
            return
        }
        self.timer = timer
        visualTimer.updateTimer(with: timer!)
    }
    
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        _startTimer()
    }
    
    func _startTimer() {
        if sessionTimer == nil {
            sessionTimer = TimerWrapper(with: timer!)
            sessionTimer?.onComplete = onComplete
        }
        
        sessionTimer?.startTimer()
        if (sessionTimer?.paused)! {
            visualTimer.resumeAnimation()
        } else {
            visualTimer.beginAnimation()
        }
        stopButton.setTitle("Pause", for: .normal)
        stopButton.isEnabled = true
        startButton.isEnabled = false
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        _stopTimer()
    }
    
    func _stopTimer(clear: Bool = false) {
        guard sessionTimer != nil else {
            log.debug("no timers running so cannot stop them")
            return
        }
        if ((sessionTimer?.isPaused())! || clear) {
            sessionTimer?.stopTimer(clear: true)
            visualTimer.clearAnimations()
            stopButton.setTitle("Pause", for: .normal)
        } else {
            sessionTimer?.stopTimer(clear: false)
            visualTimer.pauseAnimation()
            stopButton.setTitle("Reset", for: .normal)
        }
        startButton.isEnabled = true
    }
    
    func onComplete() {
        stopButton.setTitle("Reset", for: .normal)
        startButton.isEnabled = true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
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

