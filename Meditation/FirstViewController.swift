//
//  FirstViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timer: UILabel!
    var time = 60.0 //in seconds
    
    var tableCells: [TableCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timerCell = TableCell(type: .option, label: "Time", value: time)
        let countdownCell = TableCell(type: .option, label: "Countdown", value: 0.00)
        
        tableCells = [timerCell, countdownCell]
        
        //60 seconds in minute
        var seconds = time.truncatingRemainder(dividingBy: 60.0)
        var minutes = floor(time / 60)
        var hours = floor(minutes / 60)
        minutes = minutes.truncatingRemainder(dividingBy: 60.0)
        
        timer.text = "\(hours):\(minutes):\(seconds)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableCells[indexPath.row].type {
        case .picker:
            var cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell")
            return cell!
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "optionCell")
            return cell!
        }
    }
    
    // MARK: - Actions
    @IBAction func startTimer(_ sender: UIButton) {
    }

    @IBAction func stopTimer(_ sender: UIButton) {
    }
}

