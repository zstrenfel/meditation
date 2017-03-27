//
//  TimerTableViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class TimerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timers: [MeditationTimer] = []
    
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.3)
        
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
        timers = timers.sorted { $0.last_completed?.compare($1.last_completed as! Date) == ComparisonResult.orderedDescending }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //get timers from the store
    func fetchTimers() {
        do {
            timers = try context.fetch(MeditationTimer.fetchRequest())
        } catch {
            log.error("Fetching Failed")
        }
    }

    // MARK: Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meditationCell") as! MeditationDisplayTableViewCell
        let timer = timers[indexPath.row]
        cell.nameLabel.text = timer.name
        cell.durationLabel.text = Double(timer.countdown + timer.primary + timer.cooldown).longTimeString

        cell.timer = timer
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showTimer", sender: nil)
    }
    
    // MARK: - Table Row Actions
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: " Edit ", handler: editMeditation)
        edit.backgroundColor = .blue
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: confirmDelete)
        delete.backgroundColor = .red
        
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
        
        let alertController = UIAlertController(title: "Delete Timer", message: "Are you sure you wan't to delete this timer?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default , handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.context.delete(timer)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                _ = self.timers.remove(value: timer)
                self.tableView.deleteRows(at: [indexPath], with: .top)
            }
        })
        
        alertController.addAction(cancel)
        alertController.addAction(delete)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        self.performSegue(withIdentifier: "showAdmin", sender: nil)
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
