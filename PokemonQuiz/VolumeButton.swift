//
//  VolumeButton.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/19/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

@IBDesignable class VolumeButton: UIButton {
    static let SoundOff = "SoundOff"
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
    
    override func awakeFromNib() {
        isOn = !UserDefaults.standard.bool(forKey: VolumeButton.SoundOff)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isOn = !self.isOn
        UserDefaults.standard.set(!isOn, forKey: VolumeButton.SoundOff)
        UserDefaults.standard.synchronize()
    }


}
