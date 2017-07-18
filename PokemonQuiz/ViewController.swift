//
//  ViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/16/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

class ViewController: PQViewController {
    let pokgearIdentifier = "849383046"
    
    @IBOutlet weak var classicModeButton: ModeButton!
    
    @IBOutlet weak var hardModeButton: ModeButton!

    @IBOutlet weak var advanceModeButton: ModeButton!
    
    var modeButtons: [ModeButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeButtons = [classicModeButton, hardModeButton, advanceModeButton]
    }
    
    @IBAction func pokgearButtonClick(_ sender: Any) {
        self.openAppStore(for: pokgearIdentifier)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let height = self.view.bounds.height
        for button in modeButtons {
            button.center.y += height
            UIView.animate(withDuration: 0.5, animations: {
                button.center.y -= height
            }, completion: {[unowned self]_ in
                if button === self.advanceModeButton {
                    self.modeButtons = []
                }
            })
        }
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

    @IBAction func modeButtonTouchUp(_ sender: ModeButton) {
        print("touch !")
    }
}

