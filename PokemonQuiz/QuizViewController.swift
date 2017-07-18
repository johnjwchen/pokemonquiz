//
//  QuizViewController.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

enum QuizMode {
    case classic
    case hard
    case advance
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
    
    var quizMode: QuizMode = .classic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = maskImage(name: "background", color: QuizModeColor.classic)
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

    @IBAction func animate(_ sender: Any) {
        countingView.startCounting()
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
