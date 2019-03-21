//
//  NumCalcButton.swift
//  PaceCalc 3
//
//  Created by Remington Breeze on 11/2/17.
//  Copyright © 2017 Remington Breeze. All rights reserved.
//

import UIKit

class NumCalcButton: CalcButton {
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red:0.96, green:0.93, blue:0.92, alpha:1.0) : UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
