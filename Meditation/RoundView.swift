//
//  RoundView.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/24/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

@IBDesignable
class RoundView: UIView {
    
    var fillColor: UIColor = .black

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
    }

}
