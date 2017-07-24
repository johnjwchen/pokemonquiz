//
//  ResponableButton.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/20/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

@IBDesignable class ResponableButton: RoundCornerButton {
    
    @IBInspectable var highlightColor: UIColor?
    
    private var _backgroundColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _backgroundColor = self.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _backgroundColor = self.backgroundColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = highlightColor != nil ? highlightColor : UIColor.darkGray
            }
            else {
                self.backgroundColor = _backgroundColor
            }
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
