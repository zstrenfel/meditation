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


class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var cooldownLabel: UILabel!
    
    var sections: [TimerType] = [.countdown, .primary, .cooldown, .interval]
    var sectionMap: [TimerType: [TableCell]] = [:]
    
    var timerRunning: Bool = false
    
    var countdown: Double = 0.0 {
        didSet {
            //update logic goes here
            updateTimerLabels(countdown, type: .countdown)
            updateTableCells(value: countdown, type: .countdown)
        }
    }
    var primary: Double = 0.0 {
        didSet {
            //update logic goes here
            updateTimerLabels(primary, type: .primary)
            updateTableCells(value: primary, type: .primary)
        }
    }
    var cooldown: Double = 0.0 {
        
        didSet {
            //udpate logic goes here
            updateTimerLabels(cooldown, type: .cooldown)
            updateTableCells(value: cooldown, type: .cooldown)
        }
    }
    var interval: Double = 0.0 {
        didSet {
            //update logic goes here
            log.debug("interval needs to be set here")
        }
    }
    
    //what section has an active picker
    var activePickerIndexPath: IndexPath? = nil
    
    var currentTimerIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(TimePickerTableViewCell.self, forCellReuseIdentifier: "timePickerCell")
        
        //create tablecell objects and array
        let countdownCell = TableCell(type: .option, label: TimerType.countdown.rawValue, value: countdown)
        let countdownPickerCell = TableCell(type: .timePicker, label: TimerType.countdown.rawValue, value: countdown, hidden: true)
        
        let primaryCell = TableCell(type: .option, label: TimerType.primary.rawValue, value: primary)
        let primaryPickerCell = TableCell(type: .timePicker, label: TimerType.primary.rawValue, value: primary, hidden: true)
        
        let cooldownCell = TableCell(type: .option, label: TimerType.cooldown.rawValue, value: cooldown)
        let cooldownPickerCell = TableCell(type: .timePicker, label: TimerType.cooldown.rawValue, value: cooldown, hidden: true)
        
        let intervalCell = TableCell(type: .option, label: TimerType.interval.rawValue, value: interval)
        let intervalPickerCell = TableCell(type: .timePicker, label: TimerType.interval.rawValue, value: interval, hidden: true)
        
        sectionMap[.countdown] = [countdownCell, countdownPickerCell]
        sectionMap[.primary] = [primaryCell, primaryPickerCell]
        sectionMap[.cooldown] = [cooldownCell, cooldownPickerCell]
        sectionMap[.interval] = [intervalCell, intervalPickerCell]
        
        //update labels with the appropriate time
        //redundent????
        timerLabel.text = primary.timeString
        countdownLabel.text = countdown.timeString
        cooldownLabel.text = cooldown.timeString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTimerLabels(_ value: Double, type: TimerType) {
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
    
    //this is the callback passed to timer picker table view cell
    func handlePickerChange(value: Double, type: TimerType) {
        switch type {
        case .countdown:
            countdown = value
        case .primary:
            primary = value
        case .cooldown:
            cooldown = value
        case .interval:
            //do nothing
            break
        }
    }
    
    func updateTableCells(value: Double, type: TimerType) {
        if var section = sectionMap[type] {
            for var i in 0..<section.count {
                switch section[i].type {
                case .toggle:
                    break
                default:
                    section[i].value = value
                }
            }
            log.debug(section)
            self.sectionMap[type] = section
        }
        let index = sections.index(of: type)
        tableView.reloadSections(NSIndexSet(index: index!) as IndexSet, with: .none)
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTableCells = getSection(section: section)
        return sectionTableCells.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = getTableCell(indexPath: indexPath)
        
        switch tableCell.type {
        case .timePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "timePickerCell") as! TimePickerTableViewCell
            cell.updateParent = handlePickerChange
            cell.value = tableCell.value as! Double
            cell.type = TimerType(rawValue: tableCell.label)
            cell.isHidden = tableCell.hidden
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
        let sectionTableCells = getSection(section: indexPath.section)
        let tableCell = sectionTableCells[indexPath.row]
        switch tableCell.type {
        case .timePicker:
            if tableCell.hidden {
                return 0
            }
            return 150
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = getTableCell(indexPath: indexPath)
        switch tableCell.type {
        case .timePicker:
            //do nothing
            break
        case .picker:
            //do nothing
            break
        default:
            //show, hide functionality for the picker cells goes here
            let pickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            guard activePickerIndexPath != nil else {
                activePickerIndexPath = pickerIndexPath
                showCell(indexPath: pickerIndexPath)
                break
            }
            if activePickerIndexPath == pickerIndexPath {
                hideCell(indexPath: pickerIndexPath)
                activePickerIndexPath = nil
            } else {
                hideCell(indexPath: activePickerIndexPath!)
                activePickerIndexPath = pickerIndexPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.showCell(indexPath: pickerIndexPath)
                }
                
            }
            break
        }
    }
    
    func showCell(indexPath: IndexPath) {
        let sectionKey = sections[indexPath.section]
        sectionMap[sectionKey]?[indexPath.row].hidden = false
        tableView.reloadRows(at: [indexPath], with: .bottom)
    }
    
    func hideCell(indexPath: IndexPath) {
        let sectionKey = sections[indexPath.section]
        sectionMap[sectionKey]?[indexPath.row].hidden = true
        tableView.reloadRows(at: [indexPath], with: .top)
    }
    func toggleCellVisibility(indexPath: IndexPath) {
        
    }
    
    func handlePickerChange(_ hour: Int, _ minute: Int, _ second: Int) {
        let newTime = Double(hour * 3600 + minute * 60 + second)
        let sectionKey = sections[(activePickerIndexPath?.section)!]
        log.debug(sectionKey)
        sectionMap[sectionKey]?[0].value = newTime
        let parentIndexPath = IndexPath(row: 0, section: (activePickerIndexPath?.section)!) //magic numbers should not be used, change later
        tableView.reloadRows(at: [parentIndexPath], with: .none)
//        sectionMap[sectionKey][activePickerIndexPath.row - 1].value = newTime
//        let parentIndexPath = IndexPath(row: (activePickerIndexPath?.row)!
//            - 1 , section: activePickerIndexPath?.section)
//        tableView.reloadRows(at: [parentIndexPath], with: .none)
//        
//        switch timePickerCell.label {
//        case "Meditation Time":
//            if let index =  $.findIndex(timers, callback: { $0.timerType == TimerType.primary }) {
//                timers[index].update(with: newTime)
//            }
//            break
//        case "Countdown":
//            if let index =  $.findIndex(timers, callback: { $0.timerType == TimerType.countdown }) {
//                timers[index].update(with: newTime)
//            }
//            break
//        case "Cooldown":
//            if let index =  $.findIndex(timers, callback: { $0.timerType == TimerType.cooldown }) {
//                timers[index].update(with: newTime)
//            }
//            break
//        default:
//            break
//        }
        print("picker change logic goes here")
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
        _startTimer()
    }
    
    func _startTimer() {
//        guard currentTimerIndex < timers.count else {
//            print("timers are finished, can't start agin")
//            return
//        }
//        let currentTimer = timers[currentTimerIndex]
//        guard currentTimer.timer == nil else {
//            print("timer already running")
//            return
//        }
//        //if timer is paused, restart it
//        if currentTimer.isPaused() {
//            stopButton.setTitle("Pause", for: .normal)
//            currentTimer.togglePause()
//        }
//        currentTimer.startTimer()
    }

    @IBAction func stopTimer(_ sender: UIButton) {
//        let currentTimer = timers[currentTimerIndex]
//        //if current timer already paused, then clear it and reset the button label
//        if currentTimer.isPaused() {
//            stopButton.setTitle("Pause", for: .normal)
//            currentTimer.stopTime(clear: true)
//        //if timer is running, pause it
//        } else {
//            stopButton.setTitle("Reset", for: .normal)
//            currentTimer.stopTime(clear: false)
//        }
//        
//        currentTimer.togglePause()
    }
    
    // MARK: - Utility Functions
    func getSection(section: Int) -> [TableCell] {
        let sectionKey = sections[section]
        if let tableCells = sectionMap[sectionKey] {
            return tableCells
        }
        return []
    }
    
    func getTableCell(indexPath: IndexPath) -> TableCell {
        let sectionTableCells = getSection(section: indexPath.section)
        return sectionTableCells[indexPath.row]
    }
}

