

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
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        self.title = "Sounds"
        
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
        cell.selectionStyle = .none
        
        if sounds[indexPath.row] == self.selected {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
            cell.optionLabel.textColor = UIColor.darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        cell.accessoryType = .checkmark
        cell.optionLabel.textColor = UIColor.darkGray
//        cell.selectionStyle = .none
        if let block = updateParent {
            block(self.type!, cell.value!)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        cell.accessoryType = .none
        cell.optionLabel.textColor = UIColor.lightGray
    }
}
