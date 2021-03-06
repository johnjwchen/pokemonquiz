//
//  GameOverViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/19/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import Social
import MessageUI
import GameKit

class GameOverViewController: PQViewController {
    var screenShot: UIImage?
    var lastScore: Int!
    var quizMode: QuizMode = .classic
    private var timer: Timer?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messageButton: RoundCornerButton!
    @IBOutlet weak var rateButton: RoundCornerButton!
    @IBOutlet weak var facebookButton: RoundCornerButton!
    @IBOutlet weak var twitterButton: RoundCornerButton!

    @IBOutlet weak var winQuizCoinLabel: UILabel!
    
    @IBOutlet weak var classicScoreLabel: UILabel!
    @IBOutlet weak var hardScoreLabel: UILabel!
    @IBOutlet weak var advanceScoreLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberLabel.text = "0"
        descriptionLabel.text = "Points"
        if quizMode == .advance {
            descriptionLabel.text = "Experiences"
        }
        winQuizCoinLabel.isHidden = true
        if lastScore >= 600 {
            titleLabel.text = "Nice!"
        }
        if lastScore >= 600 && arc4random_uniform(3) == 0 {
            rateButton.isHidden = false
            facebookButton.isHidden = true
            twitterButton.isHidden = true
            messageButton.isHidden = true
        }
        else {
            rateButton.isHidden = true
        }
        view.backgroundColor = quizMode.color()
    
        // high socres
        classicScoreLabel.text = String(User.current.classicScore)
        hardScoreLabel.text = String(User.current.hardScore)
        advanceScoreLabel.text = "level \(User.current.gameLevel)"
        
        for v in view.subviews {
            if v !== numberLabel && v !== descriptionLabel &&
                v !== winQuizCoinLabel{
                v.alpha = 0
            }
        }
        
        if lastScore > 0 {
            timer = Timer.scheduledTimer(timeInterval: 0.9/Double(lastScore), target: self,   selector: (#selector(updateScore)), userInfo: nil, repeats: true)
        }
        else {
            animateOthers()
        }
    }
    
    
    @objc func updateScore() {
        let value = Int(numberLabel.text!)!
        if timer != nil && value >= lastScore {
            timer?.invalidate()
            timer = nil
            animateOthers()
            let cns = Setting.coins(fromScore: lastScore)
            if quizMode != .advance && cns > 0 {
                winQuizCoin(cns)
                User.current.quizCoins += cns
            }
        }
        else {
           numberLabel.text = String(value + 1)
        }
    }
    
    
    private func animateOthers() {
        UIView.animate(withDuration: 0.8, animations:{[unowned self] in
            for v in self.view.subviews {
                if v !== self.numberLabel && v !== self.descriptionLabel
                    && v !== self.winQuizCoinLabel {
                    v.alpha = 1
                }
            }
        })
    }
    
    private func winQuizCoin(_ value: Int) {
        let label = winQuizCoinLabel!
        label.text = "+ \(value) Quiz Coins"
        label.isHidden = false
        UIView.animate(withDuration: 1.6, delay: 0,
                       options: [.curveEaseOut], animations: {
            label.center.y -= 120
        }, completion: { _ in
            label.isHidden = true
        })
    }
    
    
    // MARK - social
   
    @IBAction func messageTouchUp(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            if let screenShot = screenShot,
                let imageData = UIImagePNGRepresentation(screenShot){
                messageVC.addAttachmentData(imageData, typeIdentifier: "public.data", filename: "image.png")
            }
            if let appShortUrl = Setting.main.appShortUrl,
                let url = URL(string: appShortUrl) {
                messageVC.addAttachmentURL(url, withAlternateFilename: "Pokemon Quiz")
                messageVC.body = "Checkout this awesome Pokemon Quiz. \n \(appShortUrl)"
            }
            
            self.present(messageVC, animated: true, completion: nil)
        }
        else {
            print("User hasn't setup Messages.app")
        }
    }
    
    @IBAction func facebookTouchUp(_ sender: Any) {
        post(forServiceType: SLServiceTypeFacebook)
    }
    
    private func post(forServiceType serviceType: String) {
        let postVC:SLComposeViewController = SLComposeViewController(forServiceType: serviceType)
        if let screenShot = screenShot {
            postVC.add(screenShot)
        }
        if let appShortUrl = Setting.main.appShortUrl, serviceType != SLServiceTypeFacebook {
            postVC.setInitialText("Checkout this awesome Pokemon Quiz. \n \(appShortUrl)")
        }
        self.present(postVC, animated: true, completion: nil)
    }
    
    @IBAction func backTouchUp(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func twitterTouchUp(_ sender: Any) {
        post(forServiceType: SLServiceTypeTwitter)
    }
    
    @IBAction func rateTouchUp(_ sender: Any) {
        openAppStore(for: myAppId)
    }
    
    @IBAction func viewLeaderBoardTouchUp(_ sender: Any) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = quizMode.leaderBoardId()
        present(gcVC, animated: true, completion: nil)
    }
}

extension GameOverViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension GameOverViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
