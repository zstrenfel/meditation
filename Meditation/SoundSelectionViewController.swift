

//
//  SoundSelectionViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class SoundSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sounds: [String] = [
        "bells.wav",
        "wind_chimes.wav",
        "singing_bowl.wav"
    ]
    
    var selected: String?
    
    var type: TimerType?
    var updateParent: ((_ type: TimerType, _ path: String) -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionTableViewCell
        cell.optionLabel.text = sounds[indexPath.row].titleCase()
        cell.value = sounds[indexPath.row]
        
        if sounds[indexPath.row] == self.selected {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        cell.accessoryType = .checkmark
        cell.selectionStyle = .none
        
        if let block = updateParent {
            block(self.type!, cell.value!)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}
