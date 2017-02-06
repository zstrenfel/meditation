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


class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var cooldownLabel: UILabel!
    
    var timers: [TimerClass] = []
    var tableCells: [TableCell] = []
    
    var currentTimerIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: "pickerCell")
        
        let primaryTimer = TimerClass(with: 0, alert: nil, type: .primary, callback: updateTimerLabel)
        let countdownTimer = TimerClass(with: 0, alert: nil, type: .countdown, callback: updateTimerLabel)
        let cooldownTimer = TimerClass(with: 0, alert: nil, type: .cooldown, callback: updateTimerLabel)
        
        timers = [countdownTimer, primaryTimer, cooldownTimer]
        
        let timerCell = TableCell(type: .option, label: "Meditation Time", value: primaryTimer.time)
        let countdownCell = TableCell(type: .option, label: "Countdown", value: countdownTimer.time)
        let cooldownCell = TableCell(type: .option, label: "Cooldown", value: cooldownTimer.time)
        
        tableCells = [countdownCell, timerCell, cooldownCell]
        
        timerLabel.text = primaryTimer.remaining.timeString
        countdownLabel.text = countdownTimer.remaining.timeString
        cooldownLabel.text = cooldownTimer.remaining.timeString
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTimerLabel(_ remaining: Double,_ type: TimerType) {
        switch type {
        case .countdown:
            countdownLabel.text = remaining.timeString
        case .primary:
            timerLabel.text = remaining.timeString
        case .cooldown:
            cooldownLabel.text = remaining.timeString
        }
        
        if remaining <= 0 {
            currentTimerIndex += 1
            _startTimer()
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell") as! PickerTableViewCell
            cell.setPickerCallback(handlePickerChange)
            if tableCell.value is Double {
                let value = tableCell.value as! Double
                cell.setTime(hours: Int(value.hours), minutes: Int(value.minutes), seconds: Int(value.seconds))
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionTableViewCell
            cell.optionLabel.text = tableCell.label
            switch tableCell.value {
            case let value as Double:
                cell.valueLabel.text = value.timeString
            case let value as String:
                cell.valueLabel.text = value
            default:
                cell.valueLabel.text = nil
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableCell = tableCells[indexPath.row]
        switch tableCell.type {
        case .picker:
            return 150
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableCells[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        switch tableCell.type {
        case .picker:
            //do nothing
            break
        default:
            let pickerIndex = $.findIndex(tableCells) { $0.type == CellType.picker }
            if pickerIndex != nil {
                cell.valueLabel.textColor = .black
                _removeRow(at: pickerIndex!)
                if pickerIndex != indexPath.row + 1 {
                    if pickerIndex! < indexPath.row {
                        _insertRow(at: indexPath.row, delay: 0.25)
                    } else {
                        _insertRow(at: indexPath.row + 1, delay: 0.25)
                    }
                }
            } else {
                cell.valueLabel.textColor = .red
                _insertRow(at: indexPath.row + 1)
            }
        }
    }
    
    func _insertRow(at index: Int, delay: Double = 0.0) {
        tableView.beginUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let parent = self.tableCells[index - 1]
            let pickerTableCell = TableCell(type: .picker, label: parent.label, value: parent.value)
            self.tableCells.insert(pickerTableCell, at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
        }
        tableView.endUpdates()
    }
    
    func _removeRow(at index: Int) {
        tableView.beginUpdates()
        self.tableCells.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .top)
        tableView.endUpdates()
    }
    
    func handlePickerChange(_ hour: Int, _ minute: Int, _ second: Int) {
        print("changing \(hour)")
        let pickerIndex = $.findIndex(tableCells) { $0.type == CellType.picker }
        let pickerCell = tableCells[pickerIndex!]
        let newTime = Double(hour * 3600 + minute * 60 + second)
        tableCells[pickerIndex! - 1].value = newTime
        let parentIndexPath = IndexPath(row: pickerIndex! - 1 , section: 0)
        tableView.reloadRows(at: [parentIndexPath], with: .none)
        
        switch pickerCell.label {
        case "Meditation Time":
            if let index =  $.findIndex(timers, callback: { $0.timerType == TimerType.primary }) {
                timers[index].update(with: newTime)
            }
            break
        case "Countdown":
            if let index =  $.findIndex(timers, callback: { $0.timerType == TimerType.countdown }) {
                timers[index].update(with: newTime)
            }
            break
        case "Cooldown":
            if let index =  $.findIndex(timers, callback: { $0.timerType == TimerType.cooldown }) {
                timers[index].update(with: newTime)
            }
            break
        default:
            break
        }
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        _startTimer()
    }
    
    func _startTimer() {
        guard currentTimerIndex < timers.count else {
            print("timers are finished, can't start agin")
            return
        }
        let currentTimer = timers[currentTimerIndex]
        guard currentTimer.timer == nil else {
            print("timer already running")
            return
        }
        if currentTimer.isPaused() {
            stopButton.setTitle("Pause", for: .normal)
            currentTimer.togglePause()
        }
        currentTimer.startTimer()
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        let currentTimer = timers[currentTimerIndex]
        if currentTimer.isPaused() {
            stopButton.setTitle("Pause", for: .normal)
            currentTimer.stopTime(clear: true)
        } else {
            stopButton.setTitle("Reset", for: .normal)
            currentTimer.stopTime(clear: false)
        }
        
        currentTimer.togglePause()
    }
}

