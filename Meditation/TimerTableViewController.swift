//
//  TimerTableViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class TimerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var timers: [MeditationTimer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTimers()
        tableView.reloadData()
    }
    
    //get timers from the store
    func fetchTimers() {
        do {
            timers = try context.fetch(MeditationTimer.fetchRequest())
            log.debug(self.timers)
        } catch {
            log.error("Fetching Failed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meditationCell") as! MeditationDisplayTableViewCell
        let timer = timers[indexPath.row]
        cell.nameLabel.text = timer.name != nil ? timer.name : "My Meditation"
        cell.timer = timer
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showTimer", sender: nil)
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
            log.debug(cell.timer)
            destinationVC.timer = cell.timer!
            break
        default:
            break
        }
    }

}
