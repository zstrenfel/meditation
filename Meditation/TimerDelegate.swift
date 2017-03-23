//
//  TimerDelegate.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/23/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

protocol TimerDelegate: class {
    func handleTimerComplete()
    func handleTimerChange()
}
