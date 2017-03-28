//
//  ColorPalette.swift
//  Meditation
//
//  Created by Zach Strenfel on 1/19/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import Foundation
import Hex

struct ColorPalette {
    static var red = UIColor(hex: "EF4836")
    
    struct gray {
        static var light = UIColor(hex: "EDEDED")
        static var medium = UIColor(hex: "BABABA")
        static var dark = UIColor(hex: "343838")
    }
    
    struct blue {
        static var dark = UIColor(hex: "34495E")
        static var light = UIColor(hex: "00B4CC")
    }
    
    struct pink {
        static var primary = UIColor(hex: "E25473")
        static var secondary = UIColor(hex: "DB728E")
        static var tertiary = UIColor(hex: "FC9D9A")
    }
    
    struct font {
        static var primary = UIColor(hex: "34495E")
        static var secondary = UIColor(hex: "97A0A0")
        static var headers = UIColor(hex: "343838")
    }
}
