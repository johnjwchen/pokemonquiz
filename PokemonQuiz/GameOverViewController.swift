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
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messageButton: RoundCornerButton!
    @IBOutlet weak var rateButton: RoundCornerButton!
    @IBOutlet weak var facebookButton: RoundCornerButton!
    @IBOutlet weak var twitterButton: RoundCornerButton!

    
    @IBOutlet weak var classicScoreLabel: UILabel!
    @IBOutlet weak var hardScoreLabel: UILabel!
    @IBOutlet weak var advanceScoreLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the 
        
        // 
        rateButton.isHidden = true
    }
    
   
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
        // Check the result or perform other tasks.
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
