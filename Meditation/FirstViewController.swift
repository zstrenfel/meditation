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
    
    weak var timer: Timer?
    var time: Double = 325.00 //in seconds
    var remainingTime: Double = 0.0 //don't mutate user-inputed time
    var countdownTime: Double = 10.0
    var cooldownTime: Double = 0.0
    var paused: Bool = false
    
    var tableCells: [TableCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: "pickerCell")
        
        remainingTime = time
        let timerCell = TableCell(type: .option, label: "Meditation Time", value: time)
        let countdownCell = TableCell(type: .option, label: "Countdown", value: countdownTime)
        let cooldownCell = TableCell(type: .option, label: "Cooldown", value: cooldownTime)
        
        tableCells = [timerCell, countdownCell, cooldownCell]
        
        updateTimer(with: remainingTime)
    }
    
    func updateTimer(with time: Double) {
        timerLabel.text = time.timeString
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
        switch tableCell.type {
        case .picker:
            //do nothing
            break
        default:
            let pickerIndex = $.findIndex(tableCells) { $0.type == CellType.picker }
            if pickerIndex != nil {
                _removeRow(at: pickerIndex!)
                if pickerIndex != indexPath.row + 1 {
                    if pickerIndex! < indexPath.row {
                        _insertRow(at: indexPath.row, delay: 0.25)
                    } else {
                        _insertRow(at: indexPath.row + 1, delay: 0.25)
                    }
                }
            } else {
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
           updateTimer(with: newTime)
        default:
            break
        }
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        //if timer is already running, don't do anything on start button press
        guard timer == nil else {
            print("timer start repeated press edge case")
            return
        }
        if paused {
            stopButton.setTitle("Pause", for: .normal)
            paused = false
        }
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FirstViewController.countDown), userInfo: nil, repeats: true)
    }
    
    func countDown() {
        guard remainingTime > 0 else {
            _stopTimer(clear: false) //don't end session unless the user wants to
            return
        }
        remainingTime = remainingTime - 1
        updateTimer(with: remainingTime)
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        if paused {
            stopButton.setTitle("Pause", for: .normal)
            _stopTimer(clear: true)
        } else {
            stopButton.setTitle("Reset", for: .normal)
          _stopTimer(clear: false)
        }
        
        paused = !paused
    }
    
    
    func _stopTimer(clear: Bool) {
        guard timer != nil else {
            return
        }
        
        timer!.invalidate()
        
        //if the session is ended, reset the timer
        if clear {
            self.remainingTime = self.time
            updateTimer(with: self.remainingTime)
            timer = nil
        }
    }
}

