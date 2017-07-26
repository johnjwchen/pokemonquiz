//
//  AnswerButton.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

enum AnswerButtonStatus {
    case not
    case wrong
    case correct
}

@IBDesignable class AnswerButton: RoundCornerButton {
    
    static let notColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0)
    static let wrongColor = UIColor(red:1.00, green:0.04, blue:0.18, alpha:1.0)
    static let correctColor = UIColor(red:0.00, green:0.65, blue:0.33, alpha:1.0)
    
    private var _pokemonId: Int!
    var pokemonId: Int? {
        get {
            return _pokemonId
        }
        set {
            _pokemonId = newValue
            if _pokemonId >= 0 && _pokemonId < QuizGame.pokemonNameArray.count {
                let name = QuizGame.pokemonNameArray[_pokemonId]
                setTitle(name, for: .normal)
            }
        }
    }
    
    var status: AnswerButtonStatus {
        didSet {
            switch status {
            case .not:
                self.backgroundColor = AnswerButton.notColor
            case .wrong:
                self.backgroundColor = AnswerButton.wrongColor
            case .correct:
                self.backgroundColor = AnswerButton.correctColor
            }
        }
    }
    
    override init(frame: CGRect) {
        self.status = .not
        super.init(frame: frame)
    }

    
    required init?(coder aDecoder: NSCoder) {
        self.status = .not
        super.init(coder: aDecoder)
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
