//
//  ViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/16/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit

class ViewController: PQViewController {
    let pokgearIdentifier = "849383046"
    
    @IBOutlet weak var classicModeButton: ModeButton!
    @IBOutlet weak var hardModeButton: ModeButton!
    @IBOutlet weak var quizCoinsLabel: UILabel!
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
        
        Chartboost.cacheRewardedVideo(CBLocationIAPStore)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addCoins(notification:)), name: TransationObserver.AddCoinsNotification, object: nil)
        
        authenticateLocalPlayer()
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if let viewController = viewController {
                // 1. Show login if player is not logged in
                self.present(viewController, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                User.current.gcEnabled = true
                
                // Get the default leaderboard ID
//                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
//                    if error != nil { print(error)
//                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
//                })
                
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var classicQuizArray: [Quiz]!
    private var hardQuizArray: [Quiz]!
    private var advanceQuizArray: [Quiz]!
    
    private func prepareQuiz() {
        classicQuizArray = QuizGame.quizArray(forQuizMode: .classic)
        hardQuizArray = QuizGame.quizArray(forQuizMode: .hard)
        advanceQuizArray = QuizGame.quizArray(forQuizMode: .advance)
        
        // chache images
        Downloader.cacheImages(ofPokemonIds: [classicQuizArray.first!.pokemon,
                                              hardQuizArray.first!.pokemon,
                                              advanceQuizArray.first!.pokemon])
    }
    
    fileprivate func updateQuizCoinsLabel() {
        quizCoinsLabel.text = String(format: "%d Quiz Coins", User.current.quizCoins)
    }
    
    @objc func addCoins(notification: Notification) {
        updateQuizCoinsLabel()
    }
    
    @IBAction func pokgearButtonClick(_ sender: Any) {
        openAppStore(for: pokgearIdentifier)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // prepare quiz
        prepareQuiz()
        
        // load the quiz coins
        updateQuizCoinsLabel()

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
            vc.quizArray = classicQuizArray
        case hardModeButton:
            vc.quizMode = .hard
            vc.quizArray = hardQuizArray
        default:
            if User.current.quizCoins < 1 {
                let alertVC = UIAlertController(title: "Advice", message: "You need 1 Quiz Coin to play Advance. Please play other modes to earn Coins.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Buy Quiz Coins", style: .default, handler: { (_) in
                    self.performSegue(withIdentifier: "PopoverShopSegue", sender: self)
                }))
                if Chartboost.hasRewardedVideo(CBLocationIAPStore) {
                    alertVC.addAction(UIAlertAction(title: "\(Setting.main.rewardCoins) Quiz Coins by watching Ad", style: .default, handler: { (_) in
                        Chartboost.setDelegate(self)
                        Chartboost.showRewardedVideo(CBLocationIAPStore)
                    }))
                }
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alertVC, animated: true, completion: nil)
                return
            }
            
            User.current.quizCoins -= 1
            updateQuizCoinsLabel()
            vc.quizMode = .advance
            vc.quizArray = advanceQuizArray
        }
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: ChartboostDelegate {
    
    func didCompleteRewardedVideo(_ location: String!, withReward reward: Int32) {
        if location == CBLocationIAPStore {
            User.current.quizCoins += Int(reward)
        }
    }
    
    func didDismissRewardedVideo(_ location: String!) {
        if location == CBLocationIAPStore {
            updateQuizCoinsLabel()
            quizCoinsLabel.center.y -= 40
            UIView.animate(withDuration: 0.92, delay: 0.0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: [],
                           animations: {
                            self.quizCoinsLabel.center.y += 40
            }, completion: nil)
            Chartboost.setDelegate(nil)
        }
    }
}

