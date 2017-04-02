//
//  FirstViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit
import XCGLogger
import CoreData


class FirstViewController: UIViewController, TimerDelegate {
    // MARK: - Properties
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var visualTimer: VisualTimer!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        
        if let t = timer {
            titleLabel.text = t.name
            visualTimer.updateTimer(with: t)
        }
        
        stopButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.debug("view will disappear")
        if sessionTimer != nil  && (sessionTimer?.isActive())! {
            _stopTimer(clear: true)
        }
    }
    
    func updateTimer(_ timer: MeditationTimer?) {
        log.debug("timer will udpate")
        guard timer != nil else {
            _ = navigationController?.popViewController(animated: true)
            return
        }
        self.timer = timer
        titleLabel.text = timer?.name
        visualTimer.updateTimer(with: timer!)
        sessionTimer = nil
    }
    
    // MARK: - State Restoration
    override func encodeRestorableState(with coder: NSCoder) {
        if let t = timer {
            let timerURI = t.objectID.uriRepresentation()
            coder.encode(timerURI, forKey: "timer_uri")
        }
        
        if let session = sessionTimer {
            let timeRemaining = session.timeRemaining()
            coder.encode(timeRemaining, forKey: "time_remaining")
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        let timerURI = coder.decodeObject(forKey: "timer_uri") as! URL
        let timerID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: timerURI)
        if let timer = fetchTimerWithID(timerID!) {
            self.timer = timer
            self.updateTimer(timer)
        }
        
        let timeRemaining = coder.decodeObject(forKey: "time_remaining")
        log.debug(timeRemaining)
        
        super.decodeRestorableState(with: coder)
    }
    
    func fetchTimerWithID(_ objectID: NSManagedObjectID) -> MeditationTimer? {
        do {
            let timer = try context.existingObject(with: objectID)
            return timer as? MeditationTimer
        } catch {
            log.error("couldn't find timer with ID \(objectID)")
            return nil
        }
    }
    
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        if let t = timer {
            if t.primary <= 0.0 &&
                t.countdown <= 0.0 &&
                t.cooldown <= 0.0 {
                showTimeAlert()
            } else {
                _startTimer()
            }
        }
    }
    
    func showTimeAlert() {
        let alertController = UIAlertController(title: "That Was Fast!", message: "Oh no, you didn't add any time! Edit your timer to begin your meditation.", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Okay", style: .default , handler: nil)
        alertController.addAction(confirm)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func _startTimer() {
        if sessionTimer == nil {
            sessionTimer = TimerWrapper(with: timer!)
            sessionTimer?.delegate = self
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sessionTimer = sessionTimer
            appDelegate.visualTimer = visualTimer
        }
        if (sessionTimer?.isActive())! {
            sessionTimer?.resumeTimer()
            visualTimer.resumeAnimation()
        } else {
            visualTimer.beginAnimation()
            sessionTimer?.startTimer()
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
            //create new meditation entity with uncompleted status
            let remaining = sessionTimer?.timeRemaining()
            if remaining! > 0.0 {
                createMeditationHistoryEntity(completed: false, totalTime: remaining!)
                saveContext()
            }
            
            sessionTimer?.clearTimer()
            visualTimer.clearVisualTimer()
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
        
        //create new meditation entity with completed status
        let totalTime = (timer?.countdown)! + (timer?.primary)! + (timer?.cooldown)!
        createMeditationHistoryEntity(completed: true, totalTime: totalTime)
        saveContext()
    }
    
    //creates a new
    func createMeditationHistoryEntity(completed: Bool, totalTime: Double) {
        let meditation: Meditation = Meditation(context: context)
        meditation.setValue(Date(), forKey: "created_at")
        meditation.setValue(Date(), forKey: "updated_at")
        meditation.setValue(completed, forKey: "completed")
        meditation.setValue(totalTime, forKey: "time_completed")
    }
    
    func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func handleTimerChange(value: Any) {
        if value is Double {
            visualTimer.updateTimeLabel(with: (value as! Double).timeString)
            if !visualTimer.animationsActive() {
                let time = ((timer?.countdown)! + (timer?.primary)! + (timer?.cooldown)!) - (value as! Double)
                visualTimer.setTime(with: time , animate: true)
            }
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

