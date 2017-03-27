//
//  EditModalViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/16/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import RandomColorSwift

class EditModalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timer: MeditationTimer? 
    var isNewTimer: Bool = false
    var timerNumber: Int = 0
    
    var sections: [String] = ["Title", TimerType.countdown.rawValue, TimerType.primary.rawValue, TimerType.cooldown.rawValue, TimerType.interval.rawValue, "Delete"]
    var sectionMap: [String: [TableCell]] = [:]
    
    //callback to refresh parent on modal dismiss
    var onDismiss: ((_ timer: MeditationTimer?) -> Void)?
    
    //what section has an active picker
    var activePickerIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.tableFooterView = UIView()
        tableView.register(TimePickerTableViewCell.self, forCellReuseIdentifier: "timePickerCell")
        
        let cancelButton = UIButton.init(type: .custom)
        cancelButton.setImage(UIImage.init(named: "cancel"), for: UIControlState.normal)
        cancelButton.addTarget(self, action:#selector(cancelEdit), for: UIControlEvents.touchUpInside)
        cancelButton.frame = CGRect.init(x: 0, y: 0, width: 13, height: 13)
        let barButton = UIBarButtonItem.init(customView: cancelButton)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if there is no timer passed in, create a new one
        if timer == nil {
            timer = MeditationTimer(context: context)
            isNewTimer = true
        }
        loadTableCells()
        loadTableFooterView()
    }
    
    func loadTableCells() {
        let titleCell = TableCell(type: .input, label: "Title", value: timer?.name)
        let displayTimeCell = TableCell(type: .toggle, label: "Display Time", value: timer?.display_time)
        
        //create tablecell objects and array
        let countdownCell = TableCell(type: .display, label: "Countdown", value: timer?.countdown)
        let countdownPickerCell = TableCell(type: .timePicker, label: "Countdown", value: timer?.countdown, hidden: true)
        let countdownSoundPickerCell = TableCell(type: .link, label: "Sound", value: timer?.countdown_sound)
        
        let primaryCell = TableCell(type: .display, label: "Meditation Timer", value: timer?.primary)
        let primaryPickerCell = TableCell(type: .timePicker, label: "Meditation Time", value:  timer?.primary, hidden: true)
        let primarySoundPickerCell = TableCell(type: .link, label: "Sound", value:  timer?.primary_sound)
        
        let cooldownCell = TableCell(type: .display, label: "Cooldown", value: timer?.cooldown)
        let cooldownPickerCell = TableCell(type: .timePicker, label: "Cooldown", value: timer?.cooldown, hidden: true)
        let cooldownSoundPickerCell = TableCell(type: .link, label: "Sound", value: timer?.cooldown_sound)
        
        let intervalCell = TableCell(type: .display, label: "Interval", value: timer?.interval)
        let intervalPickerCell = TableCell(type: .timePicker, label: "Interval", value: timer?.interval, hidden: true)
        let intervalSoundPickerCell = TableCell(type: .link, label: "Sound", value: timer?.interval_sound)
        let intervalToggleCell = TableCell(type: .toggle, label: "Repeat", value: false)
                
        sectionMap["Title"] = [titleCell, displayTimeCell]
        sectionMap[TimerType.countdown.rawValue] = [countdownCell, countdownPickerCell, countdownSoundPickerCell]
        sectionMap[TimerType.primary.rawValue] = [primaryCell, primaryPickerCell, primarySoundPickerCell]
        sectionMap[TimerType.cooldown.rawValue] = [cooldownCell, cooldownPickerCell, cooldownSoundPickerCell]
        sectionMap[TimerType.interval.rawValue] = [intervalCell, intervalPickerCell, intervalSoundPickerCell, intervalToggleCell]
    }
    
    func loadTableFooterView() {
        guard isNewTimer == false else {
            //no need to add the delete button if the object doesn't even exist
            return
        }
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
        customView.backgroundColor = UIColor.white
        let button = UIButton(frame: CGRect(x: (self.tableView.frame.width - 200) / 2, y: 0, width: 200, height: 50))
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        customView.addSubview(button)
        
        self.tableView.tableFooterView = customView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.type = TimerType(rawValue: tableCell.label)
            cell.timer = self.timer
            cell.updateParent = handlePickerChange
            cell.isHidden = tableCell.hidden
            cell.updateTimePickerView()
            return cell
        case .toggle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell") as! ToggleTableViewCell
            cell.updateParent = handleToggleChange
            cell.optionLabel.text = tableCell.label
            
            if let toggleValue = tableCell.value as? Bool {
                cell.toggleValue = toggleValue
            }
            return cell
        case .input:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell") as! InputTableViewCell
            cell.timer = self.timer
            cell.titleLabel.text = tableCell.label
            return cell
        case .button:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonTableViewCell
            cell.timer = self.timer
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
        case .link:
            performSegue(withIdentifier: "showSoundOptions", sender: self)
            break
        case .display:
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
        default:
            break
        }
    }
    
    //this is the callback passed to timer picker table view cell
    func handlePickerChange(value: Double, type: TimerType) {
        let sectionIndex = sections.index(of: type.rawValue)
        self.sectionMap[type.rawValue]?[0].value = value
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: sectionIndex!)], with: .none)
    }
    
    // MARK: - Cell Insertion/Deletion Logic
    
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
    
    // MARK: - Actions and Acessory Methods
    @IBAction func saveChanges(_ sender: UIBarButtonItem) {
        saveChanges()
        dismiss(shouldUpdate: true)
    }
    
    //save changes if changes were made
    func saveChanges(deleted: Bool = false) {
        //should be an if else case here
        if !deleted {
            timer?.setValue(Date(), forKey: "updated_at")
            timer?.setValue(Date(), forKey: "last_completed")
            //set name if one isn't given
            if timer?.name == nil {
                timer?.setValue("Meditation \(timerNumber + 1)", forKey: "name")
            }
            //set creation date if timer is new
            if isNewTimer {
                timer?.setValue(Date(), forKey: "created_at")
                timer?.setValue(randomColor(hue: .blue).toHexString(), forKey: "color")
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func cancelEdit() {
        if isNewTimer {
            context.reset()
        } else {
            context.rollback()
        }
        dismiss(shouldUpdate: false)
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
        let sectionIndex = sections.index(of: type.rawValue)
        sectionMap[type.rawValue]?[2].value = path
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: sectionIndex!)], with: .none)
    }
    
    func handleToggleChange(_ value: Bool,_ label: String) {
        switch label {
        case "Display Time":
            self.timer?.display_time = value
            break
        case "Repeat":
            self.timer?.interval_repeat = value
            break
        default:
            break
        }
    }
    
    func confirmDelete() {
        let alertController = UIAlertController(title: "Delete Timer", message: "Are you sure you wan't to delete this timer?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default , handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: deleteMeditationTimer)
        
        alertController.addAction(cancel)
        alertController.addAction(delete)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteMeditationTimer(sender: UIAlertAction) {
        log.info("deleteing meditation timer")
        context.delete(timer!)
        self.saveChanges(deleted: true)
        self.timer = nil
        dismiss(shouldUpdate: true)
    }
    
    //refresh parent on modal close
    func dismiss(shouldUpdate: Bool) {
        if shouldUpdate {
            if let block = onDismiss {
                block(self.timer)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSoundOptions" {
            let section = sections[(self.tableView.indexPathForSelectedRow?.section)!]
            let destinationVC = segue.destination as! SoundSelectionViewController
            destinationVC.type = TimerType(rawValue: section)
            destinationVC.updateParent = self.updateSound
            
            switch section {
            case TimerType.countdown.rawValue:
                destinationVC.selected = timer?.countdown_sound
                break
            case TimerType.primary.rawValue:
                destinationVC.selected = timer?.primary_sound
                break
            case TimerType.cooldown.rawValue:
                destinationVC.selected = timer?.cooldown_sound
                break
            case TimerType.interval.rawValue:
                destinationVC.selected = timer?.interval_sound
                break
            default:
                break
            }
        }
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
