//
//  AnalyticsViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 4/4/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController {

    @IBOutlet weak var timeFilterButton: UIButton!
    @IBOutlet weak var streakCount: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var hoursCount: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func showTimeFilterOptions(_ sender: UIButton) {
    }
}
