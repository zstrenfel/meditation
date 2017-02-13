//
//  TableCellTypes.swift
//  Meditation
//
//  Created by Zach Strenfel on 12/24/16.
//  Copyright © 2016 Zach Strenfel. All rights reserved.
//

import Foundation


struct TableCell {
    var type: CellType
    var label: String
    var value: Any?
    var hidden: Bool
    
    init(type: CellType, label: String, value: Any?, hidden: Bool = false) {
        self.type = type
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
}

