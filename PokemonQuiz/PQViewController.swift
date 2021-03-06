//
//  PQViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import StoreKit

class PQViewController: UIViewController {
    let myAppId = "1233818739"
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension PQViewController {
    func screenShotImage() -> UIImage? {
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let attributes :[String:AnyObject] = [
            NSFontAttributeName : UIFont(name: "Helvetica", size: 22)!,
            NSForegroundColorAttributeName : UIColor.white
        ]
        // Draw text with CGPoint and attributes
        if let text = Setting.main.appName {
            let attributedString = NSAttributedString(string: text as String, attributes: attributes)
            
            attributedString.draw(at: CGPoint(x: layer.frame.size.width/2 - attributedString.size().width/2, y: 10))
        }
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
}

extension PQViewController: SKStoreProductViewControllerDelegate {
    func openAppStore(for identifier: String) {
        if #available(iOS 8.0, *) {
            openProductViewController(of: identifier)
        } else {
            if let url  = URL(string: String(format: "itms://itunes.apple.com/us/app/xxxxxxxxxxx/id%s?ls=1&mt=8", identifier)),
            UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func openProductViewController(of identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters, completionBlock: nil)
        present(storeViewController, animated: true, completion: nil)
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}




