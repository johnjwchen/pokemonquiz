//
//  QuizViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import AVFoundation

extension QuizMode {
    func color() -> UIColor {
        switch self {
        case .classic:
            return QuizModeColor.classic
        case .hard:
            return QuizModeColor.hard
        case .advance:
            return QuizModeColor.advance
        }
    }
    
    func score() -> Int {
        switch self {
        case .classic:
            return 60
        case .hard:
            return 100
        case .advance:
            return 50
        }
    }
}

struct QuizModeColor {
    static var classic: UIColor {
        return UIColor(red: 38.0/255.0, green: 137.0/255.0, blue: 230.0/255.0, alpha: 1)
    }
    static var hard: UIColor {
        return UIColor(red: 1, green: 45.0/255.0, blue: 128.0/255.0, alpha: 1)
    }
    static var advance: UIColor {
        return UIColor(red: 1, green: 147.0/255.0, blue: 1.0/255.0, alpha: 1)
    }
    
}


class QuizViewController: PQViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var countingView: CountingView?
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var answer1Button: AnswerButton!
    @IBOutlet weak var answer2Button: AnswerButton!
    @IBOutlet weak var answer3Button: AnswerButton!
    @IBOutlet weak var answer4Button: AnswerButton!
    @IBOutlet weak var volumeButton: VolumeButton!
    @IBOutlet weak var winPointsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var hitLabel: UILabel!
    @IBOutlet weak var hitDescriptionLabel: UILabel!
    @IBOutlet weak var scoreDescriptionLabel: UILabel!
    
    var anserButtons: [AnswerButton]!
    
    var quizMode: QuizMode = .classic
    var quizArray: [Quiz]!
    private var quizIndex = 0
    
    private var wrongAnswer = 0
    private var maxWrongAnswers = 0
    
    private var correctPlayer: AVAudioPlayer?
    private var wrongPlayer: AVAudioPlayer?
    private var screenShot: UIImage?
    
    private var answerButtons: [AnswerButton]!
   
    private var sumExperience = 0
    
    deinit {
        Chartboost.setDelegate(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let color = quizMode.color()
        if let image = UIImage(named: "background") {
            backgroundImageView.image = ImageProcess.maskImage(image, color: color)
        }
        anserButtons = [answer1Button, answer2Button, answer3Button, answer4Button]
        
        if quizMode == .advance {
            countingView?.removeFromSuperview()
            countingView = nil
            hitLabel.text = String(User.current.gameLevel)
            hitDescriptionLabel.text = "Level"
            scoreLabel.text = String(User.current.lastExperience)
            scoreDescriptionLabel.text = "Experience"
        }
        pokemonImageView.image = nil
        
        countingView?.backgroundColor = color
        
        anserButtons = [answer1Button, answer2Button, answer3Button, answer4Button]
        
        wrongPlayer = loadPlayer(name: "wrongSound")
        correctPlayer = loadPlayer(name: "correctSound")
        
        winPointsLabel.isHidden = true
        winPointsLabel.text = "+\(quizMode.score())"
        
        Chartboost.setDelegate(self)
        Chartboost.cacheInterstitial(CBLocationGameOver)
        
        wrongAnswer = 0
        quizIndex = -1
        maxWrongAnswers = quizMode == .classic ? 3 : 1
        
        var pokemonIds = [Int]()
        for quiz in quizArray {
            pokemonIds.append(quiz.pokemon)
        }
        Downloader.cacheImages(ofPokemonIds: pokemonIds)
    }
    
    
    func setPokemonImage(ofPokemonId pokemonId: Int) {
        Downloader.loadImage(ofPokemonId: pokemonId) { image in
            if let image = image {
                if !Setting.main.useOriginPokemonImage {
                    self.pokemonImageView.image = ImageProcess.maskImage(image, color: self.quizMode.color())
                }
                else {
                    self.pokemonImageView.image = image
                }
            }
        }  
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextQuiz()
    }
    
    private func nextQuiz() {
        quizIndex += 1
        if quizIndex >= quizArray.count {
            gameOver()
        }
        else {
            let quiz = quizArray[quizIndex]
            setPokemonImage(ofPokemonId: quiz.pokemon)
            for i in 0..<quiz.random.count {
                anserButtons[i].pokemonId = quiz.random[i]
            }
            animatePokemonAndAnswers()
        }
    }
    
    
    @IBAction func volumeValueChanged(_ sender: VolumeButton) {
        if !sender.isOn {
            wrongPlayer?.stop()
            correctPlayer?.stop()
        }
    }
    
    private func playSound(correct: Bool) {
        if volumeButton.isOn {
            if correct {
                correctPlayer?.play()
            }
            else {
                wrongPlayer?.play()
            }
        }
    }
    
    @IBAction func answerButtonTouchUp(_ button: AnswerButton) {
        countingView?.stopCounting()
        if button.pokemonId == quizArray[quizIndex].pokemon {
            // correct
            playSound(correct: true)
            button.status = .correct
            let toAdd = quizMode.score()
            if let str = scoreLabel.text, let score = Int(str) {
                scoreLabel.text = String(score + toAdd)
            }
            else {
                scoreLabel.text = String(toAdd)
            }
            sumExperience += toAdd
            
            if let str = hitLabel.text, let hit = Int(str) {
                if quizMode == .advance {
                    let score = Int(scoreLabel.text!)!
                    if score >= Setting.experiencePerLevel {
                        User.current.gameLevel += 1
                        hitLabel.text = String(User.current.gameLevel)
                        scoreLabel.text = String(score - Setting.experiencePerLevel)
                    }
                }
                else {
                    hitLabel.text = String(hit + 1)
                }
            }
            else {
                hitLabel.text = "1"
            }
            animateWinPoints() {
                button.status = .not
                self.nextQuiz()
            }
        }
        else {
            // wrong
            wrongAnswer += 1
            playSound(correct: false)
            button.status = .wrong
            animateAnswer(button, completion: {_ in
                button.status = .not
                if self.wrongAnswer >= self.maxWrongAnswers {
                    self.gameOver()
                }
                else {
                    self.nextQuiz()
                }
            })
        }
    }
    
  
    @IBAction func countChange(_ sender: CountingView) {
        if sender.count == 0 {
            wrongAnswer += 1
            nextQuiz()
        }
    }
    
    private func gameOver() {
        self.countingView?.stopCounting()
        
        if quizMode == .advance,
            let str = scoreLabel.text,
            let score = Int(str) {
            User.current.lastExperience = score
        }
        User.current.gameOverTimes += 1
        print(User.current.gameOverTimes)
        if User.current.gameOverTimes > Setting.main.gameOverAdFreeTimes &&
            User.current.gameOverTimes % Setting.main.gameOverAdShowPeriod == 0 {
            Chartboost.showInterstitial(CBLocationGameOver)
        }
        else {
            presentGameOver(animated: true)
        }
    }
    
    fileprivate func presentGameOver(animated: Bool) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameOverViewController") as! GameOverViewController
        vc.screenShot = screenShot
        if let str = scoreLabel.text, let score = Int(str) {
            vc.lastScore = quizMode == .advance ? sumExperience : score
        }
        else {
            vc.lastScore = 0
        }
        vc.quizMode = self.quizMode
        vc.showAd = false
        present(vc, animated: animated, completion: nil)
    }
    
    
    func loadPlayer(name: String) -> AVAudioPlayer? {
        if let asset = NSDataAsset(name: name){
            do {
                let player = try AVAudioPlayer(data:asset.data, fileTypeHint:"mp3")
                player.volume = 0.2
                return player
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // MASK animation
    
    private func animateAnswer(_ button: UIButton, completion: @escaping (Bool) -> Void) {
        button.center.x -= 30
        UIView.animate(withDuration: 0.62, delay: 0.0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: [],
                       animations: {
                        button.center.x += 30
        }, completion: completion)
    }
    
    private func animatePokemonAndAnswers() {
        let duration = 0.5
        var delay = 0.0
        for i in 0..<anserButtons.count {
            let button = anserButtons[i]
            button.center.y += self.view.bounds.height/2
            delay += 0.1
            UIView.animate(withDuration: duration, delay: delay,
                           options: [.curveEaseOut],
                           animations: {[unowned self] in
                            button.center.y -= self.view.bounds.height/2
            },
                           completion: {[unowned self] finished in
                            if i == self.anserButtons.count - 1 {
                                self.countingView?.startCounting()
                                if self.screenShot == nil {
                                    self.screenShot = self.screenShotImage()
                                }
                            }
            })
        }
        // animate pokemon image
        pokemonImageView.center.x += self.view.bounds.width
        UIView.animate(withDuration: duration, delay: delay,
                       options: [.curveEaseOut], animations: { [unowned self] in
                        self.pokemonImageView.center.x -= self.view.bounds.width
            }, completion: nil)
    }
    
    private func animateWinPoints(completionHandler: (() -> Void)?) {
        let duration = 0.66
        let y = winPointsLabel.center.y
        winPointsLabel.center.y += 2*pokemonImageView.frame.size.height/3
        winPointsLabel.isHidden = false
        UIView.animate(withDuration: duration, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
            self.winPointsLabel.center.y = y
        }) { _ in
            self.winPointsLabel.isHidden = true
            completionHandler?()
        }
    }

}

extension QuizViewController: ChartboostDelegate {
    func didDismissInterstitial(_ location: String!) {
        if location == CBLocationGameOver {
            presentGameOver(animated: false)
        }
    }
}

