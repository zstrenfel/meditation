//
//  AdminViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/15/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import CoreData

class AdminViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func deleteAll(_ sender: UIButton) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MeditationTimer")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
//        request.resultType = NSBatchDeleteRequestResultType.resultTypeObjectIDs
        do {
            let result = try context.execute(request)
        } catch {
            log.error("could not execute request \(error)")
        }
    }

    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
