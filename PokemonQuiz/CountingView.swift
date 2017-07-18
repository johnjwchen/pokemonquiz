//
//  CountingView.swift
//  PokemonQuiz
//
//  Created by JIAWEI CHEN on 7/17/17.
//  Copyright © 2017 Pokgear Inc. All rights reserved.
//

import UIKit

@IBDesignable class CountingView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    var duration: CFTimeInterval = 15
    private var circleLayer: CAShapeLayer!
    private var timer: Timer?
    
    @IBInspectable var lineWidth: CGFloat {
        get {
            return circleLayer.lineWidth
        }
        set {
            circleLayer.lineWidth = newValue
        }
    }
    
    private var _textColor: UIColor?
    @IBInspectable var textColor: UIColor? {
        get {
            return numberLabel.textColor
        }
        set {
            numberLabel.textColor = newValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.frame will be correct here
        let mn = min(frame.size.width, frame.size.height)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (mn - 10)/2, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(3*Double.pi/2), clockwise: true)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.setNeedsDisplay()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed(String(describing: CountingView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.clear
        
        circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = textColor?.cgColor
        circleLayer.lineWidth = 5.0
        
        circleLayer.strokeEnd = 1.0
        
        layer.addSublayer(circleLayer)
    }
    
    @objc private func updateCounter() {
        if let text = numberLabel.text,
           let count = Int(text), count > 0 {
            numberLabel.text = String(count - 1)
        }
        else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    public func startCounting() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = duration
        animation.fromValue = 1.0
        animation.toValue = 0.0
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        circleLayer.strokeEnd = 0.0
        
        // time
        numberLabel.text = String(Int(duration))
        if let timer = self.timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)

        circleLayer.add(animation, forKey: "animateCircle")
    }
    
    public func resetCounting() {
        circleLayer.strokeEnd = 1.0
        circleLayer.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    

}
