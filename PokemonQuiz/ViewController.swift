//
//  ViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/16/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: PQViewController {
    let pokgearIdentifier = "849383046"
    
    @IBOutlet weak var classicModeButton: ModeButton!
    
    @IBOutlet weak var hardModeButton: ModeButton!

    @IBOutlet weak var advanceModeButton: ModeButton!
    
    var modeButtons: [ModeButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeButtons = [classicModeButton, hardModeButton, advanceModeButton]
        
        // Access the shared, singleton audio session instance
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for movie playback
            try session.setCategory(AVAudioSessionCategoryAmbient)
            try session.setActive(true)
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }

    }
    
    @IBAction func pokgearButtonClick(_ sender: Any) {
        self.openAppStore(for: pokgearIdentifier)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let height = self.view.bounds.height
        for button in modeButtons {
            button.center.y += height
            UIView.animate(withDuration: 0.6, animations: {
                button.center.y -= height
            }, completion: {[unowned self]_ in
                if button === self.advanceModeButton {
                    self.modeButtons = []
                }
            })
        }
    }


    @IBAction func modeButtonTouchUp(_ sender: ModeButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "QuizViewController") as! QuizViewController
        switch sender {
        case classicModeButton:
            vc.quizMode = .classic
        case hardModeButton:
            vc.quizMode = .hard
        default:
            vc.quizMode = .advance
        }
        self.present(vc, animated: true, completion: nil)
    }
}

