

//
//  SoundSelectionViewController.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import AVFoundation

class SoundSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sounds: [String] = [
        "none",
        "singing_bowl",
        "temple_bell",
        "two_bells",
        "zymbel"
    ]
    var soundPlayer: AVAudioPlayer?
    
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
        
        configureAudioSession()
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
        playSound(sound: sounds[indexPath.row])
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        cell.accessoryType = .checkmark
        cell.optionLabel.textColor = UIColor.darkGray
        if let block = updateParent {
            block(self.type!, cell.value!)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
        cell.accessoryType = .none
        cell.optionLabel.textColor = UIColor.lightGray
    }
    
    // MARK: - Sound Preview
    //enables sounds for silent mode
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        }
        catch {
            log.error("could not configure audio session")
        }
    }
    
    func playSound(sound: String) {
        //reset sound player
        if soundPlayer != nil {
            soundPlayer?.stop()
            soundPlayer = nil
        }
        //no preview for none
        if sound == "none" {
            return
        }
        
        if let sound = NSDataAsset(name: sound) {
            do {
                soundPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
                soundPlayer?.play()
            } catch {
                log.debug("could not find the allocated sound")
            }
        }
    }
}
