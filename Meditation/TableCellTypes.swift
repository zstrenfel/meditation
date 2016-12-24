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
}

enum CellType {
    case option
    case picker
    case toggle
    case input
}

