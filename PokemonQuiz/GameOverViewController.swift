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

class GameOverViewController: PQViewController {
    let myAppId = "1233818739"
    
    var screenShot: UIImage?
    var lastScore: Int!
    var quizMode: QuizMode = .classic
    private var timer: Timer!
    var showAd: Bool!
    
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
            rateButton.isHidden = false
            facebookButton.isHidden = true
            twitterButton.isHidden = true
            messageButton.isHidden = true
        }
        else {
            rateButton.isHidden = true
        }
        view.backgroundColor = quizMode.color()
    
        
        if showAd {
            Chartboost.showInterstitial(CBLocationGameOver)
        }
        else {
            // hide others
            for v in view.subviews {
                if v !== numberLabel && v !== descriptionLabel &&
                    v !== winQuizCoinLabel{
                    v.alpha = 0
                }
            }
        }
        
        // high socres
        classicScoreLabel.text = String(User.current.classicScore)
        hardScoreLabel.text = String(User.current.hardScore)
        advanceScoreLabel.text = "level \(User.current.gameLevel)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !showAd && lastScore > 0 {
            timer = Timer.scheduledTimer(timeInterval: 0.9/Double(lastScore), target: self,   selector: (#selector(updateScore)), userInfo: nil, repeats: true)
        }
        else {
            animateOthers()
        }
    }
    
    @objc func updateScore() {
        let value = Int(numberLabel.text!)!
        if value == lastScore {
            timer.invalidate()
            animateOthers()
            let cns = coins(fromScore: lastScore)
            if quizMode != .advance && cns > 0 {
                winQuizCoin(cns)
                User.current.quizCoins += cns
            }
        }
        else {
           numberLabel.text = String(value + 1)
        }
    }
    
    private func coins(fromScore scores: Int) -> Int {
        return scores / 165
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
    
    
    // MASK - social
   
    @IBAction func messageTouchUp(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            if let screenShot = screenShot,
                let imageData = UIImagePNGRepresentation(screenShot){
                messageVC.addAttachmentData(imageData, typeIdentifier: "public.data", filename: "image.png")
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
        if SLComposeViewController.isAvailable(forServiceType: serviceType) {
            let postVC:SLComposeViewController = SLComposeViewController(forServiceType: serviceType)
            // add content
            if let screenShot = screenShot {
                postVC.add(screenShot)
            }
            self.present(postVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Account", message: "Please login to your account.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
    
}

extension GameOverViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
