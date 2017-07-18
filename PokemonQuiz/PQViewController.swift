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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        let storeViewController = MyStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

class MyStoreProductViewController: SKStoreProductViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
