//
//  EditModalViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/16/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class EditModalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timer: MeditationTimer?
    
    var sections: [TimerType] = [.countdown, .primary, .cooldown, .interval]
    var sectionMap: [TimerType: [TableCell]] = [:]
    
    var updateParent: ((_ type: TimerType, _ info: TimerInfo) -> Void)?
    
    //what section has an active picker
    var activePickerIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.tableFooterView = UIView()
        tableView.register(TimePickerTableViewCell.self, forCellReuseIdentifier: "timePickerCell")
        
        
        //create tablecell objects and array
        let countdownCell = TableCell(type: .display, label: TimerType.countdown.rawValue, value: timer?.countdown)
        let countdownPickerCell = TableCell(type: .timePicker, label: TimerType.countdown.rawValue, value: timer?.countdown, hidden: true)
        let countdownSoundPickerCell = TableCell(type: .link, label: "Sound", value: timer?.countdown_sound)
        
        let primaryCell = TableCell(type: .display, label: TimerType.primary.rawValue, value: timer?.primary)
        let primaryPickerCell = TableCell(type: .timePicker, label: TimerType.primary.rawValue, value:  timer?.primary, hidden: true)
        let primarySoundPickerCell = TableCell(type: .link, label: "Sound", value:  timer?.primary_sound)
        
        let cooldownCell = TableCell(type: .display, label: TimerType.cooldown.rawValue, value: timer?.cooldown)
        let cooldownPickerCell = TableCell(type: .timePicker, label: TimerType.cooldown.rawValue, value: timer?.cooldown, hidden: true)
        let cooldownSoundPickerCell = TableCell(type: .link, label: "Sound", value: timer?.cooldown_sound)
        
        let intervalCell = TableCell(type: .display, label: TimerType.interval.rawValue, value: timers[.interval]?.time)
        let intervalPickerCell = TableCell(type: .timePicker, label: TimerType.interval.rawValue, value: timers[.interval]?.time, hidden: true)
        let intervalSoundPickerCell = TableCell(type: .link, label: "Sound", value: timers[.interval]?.sound)
        let intervalToggleCell = TableCell(type: .toggle, label: "Repeat", value: false)
        
        sectionMap[.countdown] = [countdownCell, countdownPickerCell, countdownSoundPickerCell]
        sectionMap[.primary] = [primaryCell, primaryPickerCell, primarySoundPickerCell]
        sectionMap[.cooldown] = [cooldownCell, cooldownPickerCell, cooldownSoundPickerCell]
        sectionMap[.interval] = [intervalCell, intervalPickerCell, intervalSoundPickerCell, intervalToggleCell]
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if there is no timer passed in, create a new one
        if timer == nil {
            timer = MeditationTimer(context: context)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this is the callback passed to timer picker table view cell
    func handlePickerChange(value: Double, type: TimerType) {
        switch type {
        case .countdown:
            self.timer?.countdown = value
            break
        case .primary:
            self.timer?.primary = value
            break
        case .cooldown:
            self.timer?.cooldown = value
            break
        case .interval:
            self.timer?.interval = value
            break
        }
        let sectionIndex = sections.index(of: type)
        self.sectionMap[type]?[0].value = value
        self.sectionMap[type]?[1].value = value
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: sectionIndex!),IndexPath(row: 1, section: sectionIndex!)], with: .none)
        
        if let block = updateParent {
            block(type, self.timer!)
        }
    }
    

    // MARK: - Table View Delegate
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
            log.debug(tableCell.value)
            cell.value = tableCell.value as! Double
            cell.type = TimerType(rawValue: tableCell.label)
            cell.isHidden = tableCell.hidden
            return cell
        case .toggle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell") as! ToggleTableViewCell
            cell.updateParent = updateRepeat
            cell.optionLabel.text = tableCell.label
            
            if let toggleValue = tableCell.value as? Bool {
                cell.toggleValue = toggleValue
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "displayCell") as! DisplayTableViewCell
            cell.titleLabel.text = tableCell.label
            switch tableCell.value {
            case let value as Double:
                cell.valueLabel.text = value.timeString
            case let value as String:
                cell.valueLabel.text = value.titleCase()
            default:
                cell.valueLabel.text = nil
            }
            
            if tableCell.type == .link {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width , height: 35))
        header.backgroundColor = ColorPalette.lightGray
        return header
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
        //disable highlighting
        self.tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        
        let tableCell = getTableCell(indexPath: indexPath)
        switch tableCell.type {
        case .timePicker:
            //do nothing
            break
        case .picker:
            //do nothing
            break
        case .link:
            performSegue(withIdentifier: "showSoundOptions", sender: self)
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
    
    // MARK: - Actions
    
    @IBAction func closeModal(_ sender: UIBarButtonItem) {
        self.saveChanges()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSoundOptions" {
            let section = sections[(self.tableView.indexPathForSelectedRow?.section)!]
            let destinationVC = segue.destination as! SoundSelectionViewController
            destinationVC.type = section
            destinationVC.updateParent = self.updateSound
            
            switch section {
            case .countdown:
                destinationVC.selected = timer?.countdown_sound
                break
            case .primary:
                destinationVC.selected = timer?.primary_sound
                break
            case .cooldown:
                destinationVC.selected = timer?.cooldown_sound
                break
            case .interval:
                destinationVC.selected = timer?.interval_sound
                break
            }
        }
    }
    
    func updateSound(_ type: TimerType, _ path: String) {
        switch type {
        case .countdown:
            timer?.countdown_sound = path
            break
        case .primary:
            timer?.primary_sound = path
            break
        case .cooldown:
            timer?.cooldown_sound = path
            break
        case .interval:
            timer?.interval_sound = path
            break
        }
        let sectionIndex = sections.index(of: type)
        sectionMap[type]?[2].value = path
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: sectionIndex!)], with: .none)
        
        if let block = updateParent {
//            block(type, self.timer!)
        }
    }
    
    func updateRepeat(_ value: Bool, _ type: TimerType) {
        self.timer.interval_repeat = value
        
        if let block = updateParent {
//            block(type, timer!)
        }
    }
    
    func updateSection(type: TimerType) {
        let section = sections.index(of: type)
        self.tableView.reloadSections(NSIndexSet(index: section!) as IndexSet, with: .none)
    }
    
    //save changes if changes were made
    func saveChanges() {
        //should be an if else case here
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    

}
