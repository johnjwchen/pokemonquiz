//
//  RoundCornerButton.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/19/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

@IBDesignable class RoundCornerButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
