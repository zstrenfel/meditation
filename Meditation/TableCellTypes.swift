//
//  TableCellTypes.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import Foundation


struct TableCell {
    var cellType: CellType
    var timerType: TimerType?
    var label: String
    var value: Any?
    var hidden: Bool
    
    init(cellType: CellType, timerType: TimerType?, label: String, value: Any?, hidden: Bool = false) {
        self.cellType = cellType
        self.timerType = timerType
        self.label = label
        self.value = value
        self.hidden = hidden
    }
}

enum CellType {
    case display
    case picker
    case timePicker
    case toggle
    case input
    case link
    case button
}

