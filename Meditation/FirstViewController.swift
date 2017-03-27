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


class FirstViewController: UIViewController, TimerDelegate {
    // MARK: - Properties
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var visualTimer: VisualTimer!
    
    //should be passed in
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timer: MeditationTimer? = nil
    
    var sessionTimer: TimerWrapper?
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waveBG = UIImage(named: "white-wave")
        let repeatingBG = UIColor(patternImage: waveBG!)
        self.view.backgroundColor = repeatingBG
                
        visualTimer.updateTimer(with: self.timer!)
        
        stopButton.isEnabled = false
        if timer?.primary == 0.0 && timer?.countdown == 0.0 && timer?.cooldown == 0.0 {
            startButton.isEnabled = false
        }
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
        sessionTimer = nil
        
        if timer?.primary != 0.0 || timer?.countdown != 0.0 || timer?.cooldown != 0.0 {
            self.startButton.isEnabled = true
        }
    }
    
    
    
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        _startTimer()
    }
    
    func _startTimer() {
        if sessionTimer == nil {
            sessionTimer = TimerWrapper(with: timer!)
            sessionTimer?.delegate = self
        }
        if (sessionTimer?.isActive())! {
            sessionTimer?.resumeTimer()
            visualTimer.resumeAnimation()
        } else {
            sessionTimer?.startTimer()
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
            sessionTimer?.clearTimer()
            visualTimer.clearAnimations()
            stopButton.setTitle("Pause", for: .normal)
            stopButton.isEnabled = false
        } else {
            sessionTimer?.stopTimer()
            visualTimer.pauseAnimation()
            stopButton.setTitle("Reset", for: .normal)
        }
        startButton.isEnabled = true
    }
    
    func handleTimerComplete(){
        stopButton.setTitle("Reset", for: .normal)
        startButton.isEnabled = true
        timer?.setValue(Date(), forKey: "last_completed")
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func handleTimerChange(value: Any) {
        if value is Double {
            visualTimer.updateTimeLabel(with: (value as! Double).timeString)
        } else if value is String {
            visualTimer.updateDescriptionLabel(with: value as! String)
        }
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

