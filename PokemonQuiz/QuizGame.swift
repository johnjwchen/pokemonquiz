//
//  QuizGame.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/24/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import Foundation

enum QuizMode {
    case classic
    case hard
    case advance
}

struct Quiz {
    let pokemon: Int
    let random: [Int]
}


class QuizGame {
    private static let pokemonGroup = QuizGame.loadJSON(name: "pokemonGroup") as! [String : Any]
    static let pokemonNameArray = QuizGame.loadJSON(name: "pokemonNameArray") as! [String]
    static let classicQuizCount = 12
    static let hardQuizCount = 10
    
    static func loadJSON(name: String) -> Any? {
        if let asset = NSDataAsset(name: name){
            return try? JSONSerialization.jsonObject(with: asset.data, options: [])
        }
        return nil
    }
    
    static func quizArray(forQuizMode quizMode: QuizMode) -> [Quiz] {
        var retArray = [Quiz]()
        switch quizMode {
        case .classic:
            for _ in 0..<classicQuizCount {
                retArray.append(classicQuiz())
            }
        case .hard:
            for _ in 0..<hardQuizCount {
                retArray.append(hardQuiz())
            }
        case .advance:
            retArray.append(advanceQuiz())
        }
        return retArray
    }
    
    static private func randomPid(ofGen gen: Int) -> Int {
        if gen == 1 {
            return Int(1 + arc4random_uniform(151))
        }
        else if gen == 2 {
            return Int(152 + arc4random_uniform(100))
        }
        else if gen == 3 {
            return Int(252 + arc4random_uniform(135))
        }
        else if gen == 4 {
            return Int(387 + arc4random_uniform(107))
        }
        else if gen == 5 {
            return Int(494 + arc4random_uniform(156))
        }
        else if gen == 6 {
            return Int(650 + arc4random_uniform(72))
        }
        else {// gen == 7
            return Int(722 + arc4random_uniform(81))
        }
    }
    
    static private func quiz(ofPid pid: Int) -> Quiz {
        var array = [Int]()
        if let group = pokemonGroup["\(pid)"] as? [Int] {
            for _ in 0..<4 {
                let index = arc4random_uniform(UInt32(group.count))
                array.append(group[Int(index)])
            }
        }
        else {
            for _ in 0..<4 {
                array.append(Int(1 + arc4random_uniform(802)))
            }
        }
        let index = Int(arc4random_uniform(4))
        array[index] = pid
        
        return Quiz(pokemon: pid, random: array)
        
    }
    static private func randomQuiz(fromGens gens: [Int]) -> Quiz {
        let index = arc4random_uniform(UInt32(gens.count))
        let gen = gens[Int(index)]
        let pid = randomPid(ofGen: gen)
        return quiz(ofPid: pid)
    }
    
    static private let classicGens = [1,1,1,2,2,2,3,3,4,4,5,5,6,7]
    static private let hardGens = [1,1,2,2,3,3,4,4,5,6,7]
    static private let advanceGens = [1,2,3,4,5,5,6,6,7,7]

    static private func classicQuiz() -> Quiz {
        return randomQuiz(fromGens: classicGens)
    }
    
    static private func hardQuiz() -> Quiz {
        return randomQuiz(fromGens: hardGens)
    }
    
    static private func advanceQuiz() -> Quiz {
        return randomQuiz(fromGens: advanceGens)
    }
}
