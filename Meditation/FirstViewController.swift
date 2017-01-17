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
    var time: Double = 325.00 //in seconds
    var remainingTime: Double = 0.0 //don't mutate user-inputed time
    
    var tableCells: [TableCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remainingTime = time
        let timerCell = TableCell(type: .option, label: "Time", value: time)
        let countdownCell = TableCell(type: .option, label: "Countdown", value: 0.00)
        
        tableCells = [timerCell, countdownCell]
        
        updateTimer(with: remainingTime)
    }
    
    func updateTimer(with: Double) {
        //60 seconds in minute
        timerLabel.text = remainingTime.timeString
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
        let tableCell = tableCells[indexPath.row]
        switch tableCell.type {
        case .picker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell")
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionTableViewCell
            cell.optionLabel.text = tableCell.label
            switch tableCell.value {
            case let value as Double:
                cell.valueLabel.text = value.timeString
            default:
                cell.valueLabel.text = ""
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableCells[indexPath.row]
        switch tableCell.type {
        case .picker:
            print("picker")
        default:
            print("other")
        }
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FirstViewController.countDown), userInfo: nil, repeats: true)
    }
    
    func countDown() {
        guard remainingTime > 0 else {
            _stopTimer(clear: true)
            return
        }
        remainingTime = remainingTime - 1
        updateTimer(with: remainingTime)
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        _stopTimer(clear: false)
    }
    
    func _stopTimer(clear: Bool) {
        timer.invalidate()
    }
}

