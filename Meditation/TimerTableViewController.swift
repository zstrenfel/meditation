//
//  TimerTableViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import Cent

class TimerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timers: [MeditationTimer] = []
    var placeholder: Int = 0
    
    private let IS_ADMIN = false
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.3)
        tableView.alwaysBounceVertical = false
        
        let addButton = UIButton.init(type: .custom)
        addButton.setImage(UIImage.init(named: "plus"), for: UIControlState.normal)
        addButton.addTarget(self, action:#selector(createNewMeditation), for: UIControlEvents.touchUpInside)
        addButton.frame = CGRect.init(x: 0, y: 0, width: 15, height: 15)
        let barButton = UIBarButtonItem.init(customView: addButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTimers()
        timers = timers.sorted { $0.last_completed?.compare($1.last_completed! as Date) == ComparisonResult.orderedDescending }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //get timers from the store
    func fetchTimers() {
        do {
            timers = try context.fetch(MeditationTimer.fetchRequest())
            shouldShowPlaceholder()
        } catch {
            log.error("Fetching Failed")
        }
    }

    // MARK: Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return placeholder
        }
        return timers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 170
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeholderCell") as! PlaceholderTableViewCell
            cell.handleNewMeditation = createNewMeditation
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "meditationCell") as! MeditationDisplayTableViewCell
            let timer = timers[indexPath.row]
            cell.selectionStyle = .none
            cell.nameLabel.text = timer.name
            cell.durationLabel.text = Double(timer.countdown + timer.primary + timer.cooldown).longTimeString
            
            cell.timer = timer
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if placeholder == 0 {
            self.performSegue(withIdentifier: "showTimer", sender: nil)
        }
    }
    
    // MARK: - Table Row Actions
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: " Edit ", handler: editMeditation)
        edit.backgroundColor = ColorPalette.pink.tertiary.withAlphaComponent(0.3)
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: confirmDelete)
        delete.backgroundColor = ColorPalette.pink.primary.withAlphaComponent(0.5)
        
        return [delete, edit]
    }
    
    func editMeditation(action: UITableViewRowAction, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MeditationDisplayTableViewCell
        let timer = cell.timer
        let editModal = UIStoryboard(name: "EditModal", bundle: nil).instantiateViewController(withIdentifier: "EditModalVC") as! EditModalViewController
        editModal.timer = timer
        editModal.onDismiss = handleNewMeditation
        
        let navigationVC = UINavigationController(rootViewController: editModal)
        self.navigationController?.present(navigationVC, animated: true, completion: nil)
    }
    
    func confirmDelete(action: UITableViewRowAction, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MeditationDisplayTableViewCell
        let timer = cell.timer! as MeditationTimer
        
        let alertController = UIAlertController(title: "Delete Timer", message: "Are you sure you want to delete this timer?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default , handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.context.delete(timer)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                _ = self.timers.remove(value: timer)
                self.tableView.deleteRows(at: [indexPath], with: .top)
                self.shouldShowPlaceholder()
                if self.placeholder == 1 {
                    self.addPlaceholder()
                }
            }
        })
        
        alertController.addAction(cancel)
        alertController.addAction(delete)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Placeholder
    func shouldShowPlaceholder() {
        if timers.count == 0 {
            placeholder = 1
        } else {
            placeholder = 0
        }
    }
    
    func addPlaceholder() {
        placeholder = 1
        let indexPath = NSIndexPath(row: 0, section: 1)
        self.tableView.insertRows(at: [indexPath as IndexPath], with: .fade)
    }
    
    // MARK: - Actions
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if IS_ADMIN {
            self.performSegue(withIdentifier: "showAdmin", sender: nil)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else {
            //break and execute segue
            return
        }
        switch segue.identifier! {
        case "showTimer":
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            let cell = self.tableView.cellForRow(at: selectedIndexPath!) as! MeditationDisplayTableViewCell
            let destinationVC = segue.destination as! FirstViewController
            destinationVC.timer = cell.timer!
            break
        case "showEditModal":
            let navigationController = segue.destination as! UINavigationController
            let editModal = navigationController.topViewController as! EditModalViewController
            editModal.onDismiss = handleNewMeditation
            editModal.timerNumber = timers.count
            break
        default:
            break
        }
    }
    
    func createNewMeditation() {
        performSegue(withIdentifier: "showEditModal", sender: nil)
    }
    
    func handleNewMeditation(_ timer: MeditationTimer?) {
        if let _ = timer {
            let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "firstVC") as! FirstViewController
            firstVC.timer = timer
            self.navigationController?.pushViewController(firstVC, animated: true)
        }
    }
}
