//
//  AnalyticsViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 4/4/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var timeFilterButton: UIButton!
    @IBOutlet weak var streakCount: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var hoursCount: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var meditations: [Meditation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMeditations()
        
        for m in self.meditations {
            log.debug(m)
        }
    }
    
    //get meditations from the store
    func fetchMeditations() {
        do {
            meditations = try context.fetch(Meditation.fetchRequest())
        } catch {
            log.error("Fetching Failed")
        }
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
        log.debug("should show time period picker")
    }
}
