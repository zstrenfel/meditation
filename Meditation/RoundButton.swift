//
//  RoundButton.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/21/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    
    @IBInspectable var fillColor: UIColor = UIColor.black

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setStroke()
        path.stroke()
    }


}
