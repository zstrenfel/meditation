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
        
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.3)

        tableView.tableFooterView = UIView()
        tableView.register(TimePickerTableViewCell.self, forCellReuseIdentifier: "timePickerCell")
        tableView.register(CustomHeaderCell.self, forCellReuseIdentifier: "headerCell")
        
        let cancelButton = UIButton.init(type: .custom)
        cancelButton.setImage(UIImage.init(named: "cancel"), for: UIControlState.normal)
        cancelButton.addTarget(self, action:#selector(cancelEdit), for: UIControlEvents.touchUpInside)
        cancelButton.frame = CGRect.init(x: 0, y: 0, width: 13, height: 13)
        let barButton = UIBarButtonItem.init(customView: cancelButton)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem?.tintColor = ColorPalette.blue.light
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
        let titleCell = TableCell(cellType: .input, timerType: nil, label: "Title", value: timer?.name)
        let displayTimeCell = TableCell(cellType: .toggle, timerType: nil, label: "Show Time Remaining", value: timer?.display_time)
        
        //create tablecell objects and array
        let countdownCell = TableCell(cellType: .display, timerType: .countdown, label: "Time", value: timer?.countdown)
        let countdownPickerCell = TableCell(cellType: .timePicker, timerType: .countdown, label: "Countdown", value: timer?.countdown, hidden: true)
        let countdownSoundPickerCell = TableCell(cellType: .link, timerType: .countdown, label: "Alert", value: timer?.countdown_sound)
        
        let primaryCell = TableCell(cellType: .display, timerType: .primary, label: "Time", value: timer?.primary)
        let primaryPickerCell = TableCell(cellType: .timePicker, timerType: .primary, label: "Meditation Time", value:  timer?.primary, hidden: true)
        let primarySoundPickerCell = TableCell(cellType: .link, timerType: .primary,  label: "Alert", value:  timer?.primary_sound)
        
        let cooldownCell = TableCell(cellType: .display, timerType: .cooldown, label: "Time", value: timer?.cooldown)
        let cooldownPickerCell = TableCell(cellType: .timePicker, timerType: .cooldown, label: "Cooldown", value: timer?.cooldown, hidden: true)
        let cooldownSoundPickerCell = TableCell(cellType: .link, timerType: .cooldown, label: "Alert", value: timer?.cooldown_sound)
        
        let intervalCell = TableCell(cellType: .display, timerType: .interval, label: "At Time", value: timer?.interval)
        let intervalPickerCell = TableCell(cellType: .timePicker, timerType: .interval, label: "Interval", value: timer?.interval, hidden: true)
        let intervalSoundPickerCell = TableCell(cellType: .link, timerType: .interval, label: "Alert", value: timer?.interval_sound)
        let intervalToggleCell = TableCell(cellType: .toggle, timerType: .interval, label: "Repeat", value: timer?.interval_repeat)
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionTableCells = getSection(section: indexPath.section)
        let tableCell = sectionTableCells[indexPath.row]
        switch tableCell.cellType {
        case .timePicker:
            if tableCell.hidden {
                return 0
            }
            return 150
        default:
            return 50
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = getTableCell(indexPath: indexPath)
        switch tableCell.cellType {
        case .timePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "timePickerCell") as! TimePickerTableViewCell
            cell.type = tableCell.timerType
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
            
            if tableCell.cellType == .link {
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
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! CustomHeaderCell
        let containerView = UIView(frame:header.frame)
        header.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        header.backgroundColor = UIColor(hex: "F2F2F2")
        header.label.text =  section == (sections.count - 1) ? "" : sections[section]
        containerView.addSubview(header)
        return containerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //disable highlighting
        self.tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        
        let tableCell = getTableCell(indexPath: indexPath)
        if tableCell.cellType != .input {
            dismissKeyboard()
        }
        switch tableCell.cellType {
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
            //set name if one isn't given
            if timer?.name == nil {
                timer?.setValue("Meditation \(timerNumber + 1)", forKey: "name")
            }
            //set creation date if timer is new
            if isNewTimer {
                //will float to top of list
                timer?.setValue(Date(), forKey: "last_completed")
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
        case "Show Time Remaining":
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
        let alertController = UIAlertController(title: "Delete Timer", message: "Are you sure you want to delete this timer?", preferredStyle: .alert)
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
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
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
