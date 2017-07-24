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
            hitDescriptionLabel.text = "Level"
            scoreDescriptionLabel.text = "Experience"
        }
        pokemonImageView.image = nil
        
        countingView?.backgroundColor = color
        
        anserButtons = [answer1Button, answer2Button, answer3Button, answer4Button]
        
        wrongPlayer = loadPlayer(name: "wrongSound")
        correctPlayer = loadPlayer(name: "correctSound")
        
        self.winPointsLabel.isHidden = true
        
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
            if let str = scoreLabel.text, let score = Int(str) {
                scoreLabel.text = String(score + 50)
            }
            else {
                scoreLabel.text = "50"
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
        if screenShot == nil {
            screenShot = screenShotImage()
        }
        if sender.count == 0 {
            wrongAnswer += 1
            nextQuiz()
        }
    }
    
    private func gameOver() {
        self.countingView?.stopCounting()
        
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
            vc.lastScore = score
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
        let y = self.winPointsLabel.center.y
        self.winPointsLabel.isHidden = false
        UIView.animate(withDuration: duration, delay: 0,
                       options: [.curveEaseOut],
                       animations: { [unowned self] in
            self.winPointsLabel.center.y -= 142
        }) {[unowned self] _ in
            self.winPointsLabel.isHidden = true
            self.winPointsLabel.center.y = y
            completionHandler?()
        }
    }
    
    @IBAction func animate(_ sender: Any) {
        animateWinPoints(completionHandler: nil)
    }
}

extension QuizViewController: ChartboostDelegate {
    func didDismissInterstitial(_ location: String!) {
        if location == CBLocationGameOver {
            presentGameOver(animated: false)
        }
    }
}

