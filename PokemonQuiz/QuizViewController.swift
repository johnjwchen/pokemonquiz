//
//  QuizViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit
import AVFoundation

enum QuizMode {
    case classic
    case hard
    case advance
    
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
    @IBOutlet weak var countingView: CountingView!
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var answer1Button: AnswerButton!
    @IBOutlet weak var answer2Button: AnswerButton!
    @IBOutlet weak var answer3Button: AnswerButton!
    @IBOutlet weak var answer4Button: AnswerButton!
    
    var anserButtons: [AnswerButton]!
    
    var quizMode: QuizMode = .classic
    
    private var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = maskImage(name: "background", color: quizMode.color())
        countingView.backgroundColor = quizMode.color()
        
        anserButtons = [answer1Button, answer2Button, answer3Button, answer4Button]
        
        // Do any additional setup after loading the view.
    }
    
    func maskImage(name:String, color:UIColor) -> UIImage {
        let image = UIImage(named: name)
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image!.size.width, height: image!.size.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image!.scale)
        let c:CGContext = UIGraphicsGetCurrentContext()!
        image?.draw(in: rect)
        c.setFillColor(color.cgColor)
        c.setBlendMode(CGBlendMode.sourceAtop)
        c.fill(rect)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }

    @IBAction func answerButtonClick(_ sender: Any) {
        playSound(name: "wrongSound")
    }
  
    @IBAction func countChange(_ sender: CountingView) {
        print(sender.count)
        if sender.count == 0 {
            self.animate(self)
        }
    }
    
    func playSound(name: String) {
        // Fetch the Sound data set.
        if let asset = NSDataAsset(name: name){
            
            do {
                // Use NSDataAsset's data property to access the audio file stored in Sound.
                player = try AVAudioPlayer(data:asset.data, fileTypeHint:"mp3")
                // Play the above sound file.
                player?.play()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func animate(_ sender: Any) {
        let duration = 0.5
        var delay = 0.0
        for i in 0..<anserButtons.count {
            let button = anserButtons[i]
            button.center.y += self.view.bounds.height/2
            delay += 0.1
            UIView.animate(withDuration: duration, delay: delay,
                           options: [.curveEaseOut],
                           animations: {
                            button.center.y -= self.view.bounds.height/2
            },
                           completion: {[unowned self] finished in
                            if i == self.anserButtons.count - 1 {
                                self.countingView.startCounting()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
