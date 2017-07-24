//
//  ShopViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/18/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire


class ShopViewController: PQViewController {
    fileprivate var productDictionary = [String: SKProduct]()
    fileprivate static let buy50CoinsProductId = "com.pokgear.pokemonquiz.50coins"
    fileprivate static let buy150CoinsProductId = "com.pokgear.pokemonquiz.150coins"
    fileprivate static let buy500CoinsProductId = "com.pokgear.pokemonquiz.500coins"
    
    fileprivate static let coinsDictionary = [buy50CoinsProductId: 50, buy150CoinsProductId: 150, buy500CoinsProductId: 500]
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ativityIndicatorView: UIActivityIndicatorView?
    
    @IBOutlet weak var addCoinsLabel: UILabel!
    fileprivate var coinsToAdd = 0
    
    @IBOutlet weak var buy50CoinsButton: ResponableButton!
    @IBOutlet weak var buy150CoinsButton: ResponableButton!
    @IBOutlet weak var buy500CoinsButton: ResponableButton!
    @IBOutlet weak var watchAdButton: ResponableButton!
    
    fileprivate var buyButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popoverPresentationController!.delegate = self

        requestAllProducts()
        buyButtons = [buy50CoinsButton, buy150CoinsButton, buy500CoinsButton, watchAdButton]
        for button in buyButtons {
            button.isHidden = true
        }
        
        Chartboost.setDelegate(self)
        NotificationCenter.default.addObserver(self, selector: #selector(addCoins(notification:)), name: TransationObserver.AddCoinsNotification, object: nil)
    }
    
    deinit {
        Chartboost.setDelegate(nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func addCoins(notification: Notification) {
        let coins = notification.object as! Int
        coinsToAdd = coins
        animateAddCoins()
    }

    fileprivate func animateAddCoins() {
        if coinsToAdd > 0 {
            addCoinsLabel.text = "+ \(coinsToAdd) Quiz Coins"
            addCoinsLabel.isHidden = false
            coinsToAdd = 0

            self.addCoinsLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            UIView.animate(withDuration: 0.6,
                animations: {[unowned self] in
                self.addCoinsLabel.transform = CGAffineTransform.identity
            },
                completion: { _ in
                    UIView.animate(withDuration: 0.6, delay: 1,
                                   options:[.curveEaseIn],
                                   animations: {[unowned self] in
                                    self.addCoinsLabel.center.y -= 80
                                    self.addCoinsLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                        }, completion: {[unowned self] _ in
                            self.addCoinsLabel.isHidden = true
                            self.addCoinsLabel.center.y += 80
                            self.addCoinsLabel.transform = CGAffineTransform.identity
                    })
                    
            })
        }
    }
    
    @IBAction func buyButtonTouchUp(sender: AnyObject) {
        if sender === self.buy50CoinsButton {
            buyProduct(ofProductId: ShopViewController.buy50CoinsProductId)
        }
        else if sender === self.buy150CoinsButton {
            buyProduct(ofProductId: ShopViewController.buy150CoinsProductId)
        }
        else if sender === self.buy500CoinsButton {
            buyProduct(ofProductId: ShopViewController.buy500CoinsProductId)
        }
        else {
            Chartboost.showRewardedVideo(CBLocationIAPStore)
        }
    }
    
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ShopViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.backButton.removeFromSuperview()
    }
}

extension ShopViewController: SKProductsRequestDelegate {
    func requestAllProducts() {
        let productsRequest = SKProductsRequest(productIdentifiers: [
            ShopViewController.buy50CoinsProductId,
            ShopViewController.buy150CoinsProductId,
            ShopViewController.buy500CoinsProductId
            ])
        productsRequest.delegate = self
        productsRequest.start()
        
    }
    
    func buyProduct(ofProductId productId: String) {
        if SKPaymentQueue.canMakePayments() {
            if let product = productDictionary[productId] {
                let payment = SKMutablePayment(product: product)
                payment.applicationUsername = User.current.uuid
                SKPaymentQueue.default().add(payment)
            }
        }
        else {
            let alertVC = UIAlertController(title: nil, message:"Purchases are disabled in your device.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        for p in products {
            productDictionary[p.productIdentifier] = p
        }
        for button in buyButtons {
            button.isHidden = false
        }
        ativityIndicatorView?.stopAnimating()
        ativityIndicatorView?.removeFromSuperview()
    }

}

extension ShopViewController: ChartboostDelegate {
    func didCache(inPlay location: String!) {
        if location == CBLocationIAPStore {
            watchAdButton.isHighlighted = false
        }
    }
    
    func didCompleteRewardedVideo(_ location: String!, withReward reward: Int32) {
        if location == CBLocationIAPStore {
            coinsToAdd = Int(reward)
            User.current.quizCoins += coinsToAdd
            
        }
    }
    
    func didDismissRewardedVideo(_ location: String!) {
        if location == CBLocationIAPStore {
            animateAddCoins()
        }
    }
}


class TransationObserver: NSObject, SKPaymentTransactionObserver {
    static let AddCoinsNotification = NSNotification.Name(rawValue: "AddCoinsNotification")
    static let main = TransationObserver()
    override private init(){
        super.init()
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred: break
                
            case .purchasing: break
                
            case .failed: break
                
            case .restored: break
            }
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let productId = transaction.payment.productIdentifier
            APIClient.main.verify(transaction: transaction) { response in
                switch response.result {
                case .success(let json):
                    if let coins = ShopViewController.coinsDictionary[productId] {
                        User.current.quizCoins += coins
                        NotificationCenter.default.post(name: TransationObserver.AddCoinsNotification, object: coins as NSNumber)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
