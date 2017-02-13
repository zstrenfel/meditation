

//
//  SoundSelectionViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class SoundSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var sounds: [String] = ["Bells"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(DisplayTableViewCell.self, forCellReuseIdentifier: "displayCell")

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayCell") as! DisplayTableViewCell
        cell.titleLabel.text = sounds[indexPath.row]
        return cell
    }
}
