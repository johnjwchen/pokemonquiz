//
//  User.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/25/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import Foundation
import GameKit

class User {
    static let current = User()
    private let keychain = KeychainSwift()
    private var quizCoinsValue: Int
    private var gameOverTimesValue: Int
    
    private let GameOverTimesKey = "GameOverTimes"
    private let QuizCoinsKey = "QuizCoins"
    
    private static let uuidKey = "UUID"
    let uuid: String
    
    // Game Center
    var gcEnabled = false
    //var gcDefaultLeaderBoard = String()
    
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
    
    private var gameOverAdWaitingValue = false
    private let gameOverAdWaitingKey = "gameOverAdWaiting"
    var gameOverAdWaiting: Bool {
        get { return gameOverAdWaitingValue }
        set {
            gameOverAdWaitingValue = newValue
            keychain.set(newValue, forKey: gameOverAdWaitingKey)
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
            sumbitToGameCenter(score: newValue, mode: .advance)
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
            sumbitToGameCenter(score: newValue, mode: .hard)
            UserDefaults.standard.synchronize()
        }
    }
    
    var classicScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: classicScoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: classicScoreKey)
            sumbitToGameCenter(score: newValue, mode: .classic)
            UserDefaults.standard.synchronize()
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
        
        if let uid = keychain.get(User.uuidKey) {
            uuid = uid
        }
        else {
            uuid = UUID().uuidString
            keychain.set(uuid, forKey: User.uuidKey)
        }
        
        if let waiting = keychain.getBool(gameOverAdWaitingKey) {
            gameOverAdWaitingValue = waiting
        }
        else {
            gameOverAdWaitingValue = false
            keychain.set(gameOverAdWaitingValue, forKey: gameOverAdWaitingKey)
        }
    }
    
    func sync() {
        
    }
}

extension QuizMode {
    func leaderBoardId() -> String {
        switch self {
        case .classic:
            return "grp.pokgear.pokemonquiz.classic"
        case .hard:
            return "grp.pokgear.pokemonquiz.hard"
        case .advance:
            return "grp.pokgear.pokemonquiz.level"
        }
    }
}

extension User {
    func sumbitToGameCenter(score: Int, mode: QuizMode) {
        let bestScoreInt = GKScore(leaderboardIdentifier: mode.leaderBoardId())
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
}
