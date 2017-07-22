//
//  Helper.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/20/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import Foundation
import UIKit

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
    class func imageURL(ofPokemonId pokemonid: UInt32) -> URL? {
        return URL(string: String(format: "https://pokedex.me/new-pokemon/480/%03d.png", pokemonid))
    }
}

class Setting {
    static let main = Setting()
    private init() {
        
    }
    
    var gameOverAdShowPeriod = 5
    var gameOverAdFreeTimes = 15
}

class User {
    static let current = User()
    private let keychain = KeychainSwift()
    private var quizCoinsValue: Int
    private var gameOverTimesValue: Int
    
    private let GameOverTimesKey = "GameOverTimes"
    private let QuizCoinsKey = "QuizCoins"
    
    
    var quizCoins: Int {
        get { return quizCoinsValue }
        set {
            quizCoinsValue = newValue
            keychain.set(String(quizCoinsValue), forKey: QuizCoinsKey)
        }
    }
    var gameOverTimes: Int {
        get { return gameOverTimesValue }
        set {
            gameOverTimesValue = newValue
            keychain.set(String(gameOverTimesValue), forKey: GameOverTimesKey)
        }
    }
    private init() {
        if let str = keychain.get(QuizCoinsKey),
            let coins = Int(str) {
            quizCoinsValue = coins
        }
        else {
            quizCoinsValue = 0
        }
        
        if let str = keychain.get(GameOverTimesKey),
            let times = Int(str) {
            gameOverTimesValue = times
        }
        else {
            gameOverTimesValue = 0
        }
        
    }
    
    func sync() {
        
    }
}
