//
//  AnswerButton.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

class AnswerButton: UIButton {
    
    var _pokemonId: Int!
    var pokemonId: Int? {
        get {
            return _pokemonId
        }
        set {
            _pokemonId = newValue
            // todo: set the name 
        }
    }
    private var _backgroundColor: UIColor?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _backgroundColor = self.backgroundColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundColor = UIColor.darkGray
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
