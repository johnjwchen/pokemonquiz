//
//  VolumeButton.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/19/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

@IBDesignable class VolumeButton: UIButton {
    static let onImage = UIImage(named: "volume-on")
    static let offImage = UIImage(named: "volume-off")
    @IBInspectable var isOn: Bool {
        get {
            return image(for: .normal) === VolumeButton.onImage
        }
        set {
            let oldValue = isOn
            if newValue != oldValue {
                setImage(newValue ? VolumeButton.onImage : VolumeButton.offImage, for: .normal)
                sendActions(for: .valueChanged)
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
