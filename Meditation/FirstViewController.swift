//
//  FirstViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    var timer = Timer()
    var time = 325.00 //in seconds
    
    var tableCells: [TableCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timerCell = TableCell(type: .option, label: "Time", value: time)
        let countdownCell = TableCell(type: .option, label: "Countdown", value: 0.00)
        
        tableCells = [timerCell, countdownCell]
        
        updateTimer()
    }
    
    func updateTimer() {
        //60 seconds in minute
        var time = self.time
        let hours = floor(time / 3600.00)
        time = time.truncatingRemainder(dividingBy: 3600.00)
        let minutes = floor(time / 60.00)
        time = time.truncatingRemainder(dividingBy: 60.00)
        let seconds = time
        
        timerLabel.text = "\(Int(hours)):\(Int(minutes)):\(Int(seconds))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableCells[indexPath.row].type {
        case .picker:
            var cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell")
            return cell!
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "optionCell")
            return cell!
        }
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FirstViewController.countDown), userInfo: nil, repeats: true)
    }
    
    func countDown() {
        guard time > 0 else {
            stopTimer(clear: true)
            return
        }
        time = time - 1
        updateTimer()
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        stopTimer(clear: false)
    }
    
    func stopTimer(clear: Bool) {
        timer.invalidate()
    }
}

