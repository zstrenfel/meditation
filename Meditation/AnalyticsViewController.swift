//
//  AnalyticsViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 4/4/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

enum TimeFilter: String {
    case all = "All"
    case daily = "By Day"
    case weekly = "By Week"
    case monthly = "By Month"
}

class AnalyticsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var timeFilterButton: UIButton!
    @IBOutlet weak var streakCount: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var hoursCount: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    private var filter: TimeFilter = .all
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var meditations: [Meditation] = []
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMeditations()
        filterMeditations()
        sortMeditations()
        
        createTimeCount()
        createStreakCount()
    }
    
    
    //get meditations from the store
    func fetchMeditations() {
        do {
            meditations = try context.fetch(Meditation.fetchRequest())
        } catch {
            log.error("Fetching Failed")
        }
    }
    
    func filterMeditations() {
        var title = ""
        switch filter {
        case .daily:
            //filter by day
            title = TimeFilter.daily.rawValue
            break
        case .weekly:
            //filter by week
            title = TimeFilter.weekly.rawValue
            break
        case .monthly:
            title = TimeFilter.monthly.rawValue
            //filter by month
            break
        default:
            title = TimeFilter.all.rawValue
            //do nothing, show all meditations
            break
        }
        timeFilterButton.setTitle(title, for: .normal)
    }
    
    func sortMeditations() {
        meditations = meditations.sorted { $0.created_at?.compare($1.created_at! as Date) == ComparisonResult.orderedDescending }
    }
    
    //create the text for hours count and label (total number of meditation hours sat)
    func createTimeCount() {
        guard meditations.count > 0 else {
            log.error("nothing to do here")
            return
        }
        let totalTime = meditations.reduce(0.0) { $0 + $1.time_completed }
        hoursCount.text = String(describing: Int(totalTime.hours))
        let pluralize = totalTime.hours > 1.0 ? "Hours" : "Hour"
        hoursLabel.text = "\(pluralize) Sat"
    }
    
    func createStreakCount() {
        guard meditations.count > 0 else {
            log.error("nothing to do here")
            return
        }
        let latest = meditations.first()
        // for future, can i do this w/o having to iterate over all meditations?
        let streak = meditations.reduce(0) {
            return $1.created_at == latest?.created_at ? $0 + 1 : $0
        }
        
        streakCount.text = String(describing: streak)
        streakLabel.text = "Day Streak"
    }
    
    // MARK: - Actions
    
    @IBAction func showTimeFilterOptions(_ sender: UIButton) {
        log.debug("should show time period picker")
    }
}
