//
//  Helper.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/20/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import Alamofire
import Kingfisher

class ImageProcess {
    class func maskImage(_ image:UIImage, color:UIColor) -> UIImage {
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image.size.width, height: image.size.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        let c:CGContext = UIGraphicsGetCurrentContext()!
        image.draw(in: rect)
        c.setFillColor(color.cgColor)
        c.setBlendMode(CGBlendMode.sourceAtop)
        c.fill(rect)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
}

class Downloader {
    class func loadImage(ofPokemonId pokemonid: Int, completionHandler:  ((UIImage?) -> Void)?) {
        if let url = URL(string: String(format: "https://pokedex.me/new-pokemon/480/%03d.png", pokemonid)) {
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) {
                (image, error, cacheType, url) in
                completionHandler?(image)
            }
        }
    }
    
    class func cacheImages(ofPokemonIds array: [Int]) {
        for pid in array {
            loadImage(ofPokemonId: pid, completionHandler: nil)
        }
    }
}


class APIClient {
    static let main = APIClient()
    let baseUrl = "https://pokemonquiz.pokgear.com/v1/"
    private init() {
        
    }
    
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    func verify(transaction: SKPaymentTransaction, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
            let receipt = NSData(contentsOf: receiptURL),
            let packageName = Bundle.main.bundleIdentifier,
            let transactionId = transaction.transactionIdentifier else {
                return
        }
        let productId = transaction.payment.productIdentifier
        let params = [
            "receipt": receipt.base64EncodedString(),
            "productId": productId,
            "packageName": packageName,
            "transactionId": transactionId
        ]
        
        Alamofire.request(baseUrl + "verifyIAP", method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON(queue: utilityQueue) { response in
            DispatchQueue.main.async {
                completionHandler(response)
            }
        }
    }
    
    func getSetting(completionHandler: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(baseUrl + "setting").validate().responseJSON(queue: utilityQueue) { response in
            DispatchQueue.main.async {
                completionHandler(response)
            }
        }
    }
}


class Setting {
    static let experiencePerLevel = 200
    
    static let main = Setting()
    private var dict = [String: Any]()
    private let gameOverAdShowPeriodKey = "gameOverAdShowPeriod"
    private let gameOverAdFreeTimesKey = "gameOverAdFreeTimes"
    private let useOriginPokemonImageKey = "useOriginPokemonImage"
    private let rewardCoinsKey = "rewardCoins"
    
    private init() {
        setDefault()
    }
    private func setDefault() {
        if dict[gameOverAdShowPeriodKey] == nil {
            dict[gameOverAdShowPeriodKey] = 5
        }
        if dict[gameOverAdFreeTimesKey] == nil {
            dict[gameOverAdFreeTimesKey] = 15
        }
        if dict[useOriginPokemonImageKey] == nil {
            dict[useOriginPokemonImageKey] = false
        }
        if dict[rewardCoinsKey] == nil {
            dict[rewardCoinsKey] = 5
        }
    }
    
    func sync() {
        APIClient.main.getSetting() {[weak self] response in
            switch response.result {
            case .success(let json):
                self?.dict = json as! [String : Any]
                self?.setDefault()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    var gameOverAdShowPeriod: Int {
        return dict[gameOverAdShowPeriodKey] as! Int
    }
    var gameOverAdFreeTimes: Int {
        return dict[gameOverAdFreeTimesKey] as! Int
    }
    var useOriginPokemonImage: Bool {
        return dict[useOriginPokemonImageKey] as! Bool
    }
    var rewardCoins: Int {
        return dict[rewardCoinsKey] as! Int
    }
    
    var dictionary: [String : Any] {
        return dict
    }
    
    var appShortUrl: String? {
        return dict["shortiOSUrl"] as? String
    }
    
    var appName: String? {
        return dict["appName"] as? String
    }
}

class User {
    static let current = User()
    private let keychain = KeychainSwift()
    private var quizCoinsValue: Int
    private var gameOverTimesValue: Int
    
    private static let GameOverTimesKey = "GameOverTimes"
    private static let QuizCoinsKey = "QuizCoins"
    
    private static let uuidKey = "UUID"
    let uuid: String
    
    
    var quizCoins: Int {
        get { return quizCoinsValue }
        set {
            quizCoinsValue = newValue
            keychain.set(String(quizCoinsValue), forKey: User.QuizCoinsKey)
        }
    }
    var gameOverTimes: Int {
        get { return gameOverTimesValue }
        set {
            gameOverTimesValue = newValue
            keychain.set(String(gameOverTimesValue), forKey: User.GameOverTimesKey)
        }
    }
    
    private let gameLevelKey = "gameLevel"
    private let hardScoreKey = "hardScore"
    private let classicScoreKey = "classicScore"
    private let lastExperienceKey = "lastExperience"
    
    var gameLevel: Int {
        get {
            return UserDefaults.standard.integer(forKey: gameLevelKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: gameLevelKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var lastExperience: Int {
        get {
            return UserDefaults.standard.integer(forKey: lastExperienceKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastExperienceKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var hardScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: hardScoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hardScoreKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var classicScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: classicScoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: classicScoreKey)
        }
    }
    
    
    private init() {
        if let str = keychain.get(User.QuizCoinsKey),
            let coins = Int(str) {
            quizCoinsValue = coins
        }
        else {
            quizCoinsValue = 0
        }
        
        if let str = keychain.get(User.GameOverTimesKey),
            let times = Int(str) {
            gameOverTimesValue = times
        }
        else {
            gameOverTimesValue = 0
        }
        
        if let uid = keychain.get(User.uuidKey) {
            uuid = uid
        }
        else {
            uuid = UUID().uuidString
            keychain.set(uuid, forKey: User.uuidKey)
        }
    }
    
    func sync() {
        
    }
}
