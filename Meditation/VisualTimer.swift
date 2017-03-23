//
//  VisualTimer.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/22/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import QuartzCore


@IBDesignable
class VisualTimer: UIView {
    
    //    weak var delegate: VisualTimerDelegate? = nil
    
    //Time Variables
    var timer: MeditationTimer? = nil {
        didSet {
            updateTimer(with: timer!)
        }
    }
    
    var started: Bool = false
    var paused: Bool = false
    var countdown: Double = 0.0
    var primary: Double = 0.0
    var cooldown: Double = 0.0
    var time: Double = 0.0
    
    var interval: Double? = 0.0
    var intervalRepeat: Bool = true
    
    //Visual Design Variables
    
    //Colors
    @IBInspectable var baseTrackColor: UIColor = UIColor.black.withAlphaComponent(0.03)
    @IBInspectable var primaryTrackColor: UIColor = UIColor.darkGray
    @IBInspectable var secondaryTrackColor: UIColor = UIColor.lightGray
    @IBInspectable var indicatorColor: UIColor = UIColor(red: 82/255, green: 179/255, blue: 217/255, alpha: 1.0)
    @IBInspectable var timerFontColor: UIColor = .darkGray
    @IBInspectable var descriptionFontColor: UIColor = .gray
    
    
    var inset: CGFloat = 8.0
    var trackWidth: Double = 10.0
    var degreeOfRotation: Double = M_PI_2
    
    //CoreGraphics Layers
    let baseTrackLayer = CAShapeLayer()
    let startIndicator = CAShapeLayer()
    
    let countdownLayer = CAShapeLayer()
    let countdownIndicator = CAShapeLayer()
    
    let primaryLayer = CAShapeLayer()
    let primaryIndicator = CAShapeLayer()
    
    let cooldownLayer = CAShapeLayer()
    
    let indicatorLayer = CALayer()
    var indicatorRadius: CGFloat = 5.0
    var intervalLayers: [CAShapeLayer] = []
    
    //Labels
    let timeLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateLayerFrames()
    }
    
    func updateTimer(with timer: MeditationTimer) {
        self.countdown = timer.countdown
        self.primary = timer.primary
        self.cooldown = timer.cooldown
        self.interval = timer.interval
        self.intervalRepeat = timer.interval_repeat
        self.time = countdown + primary + cooldown
        
        if interval != nil && interval! > 0.0 {
            createIntervalLayers()
        }
    }
    
    func createIntervalLayers() {
        let intervalCount = !intervalRepeat ? 1 : Int(floor(primary/interval!))
        for _ in 0..<intervalCount {
            let intervalLayer = CAShapeLayer()
            intervalLayers.append(intervalLayer)
        }
    }
    
    func updateLayerFrames() {
        createLabels()
        
        drawTrack(startAngle: 0.0, endAngle: CGFloat(2 * M_PI), width: trackWidth + 5.0, visible: true, color: baseTrackColor.cgColor, layer: baseTrackLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(0.0)), endAngle:  CGFloat(valueToRadians(countdown)), width: trackWidth, color: secondaryTrackColor.cgColor, layer: countdownLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(countdown)), endAngle:  CGFloat(valueToRadians(primary + countdown)), width: trackWidth, color: primaryTrackColor.cgColor, layer: primaryLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(primary + countdown)), endAngle:  CGFloat(valueToRadians(time)), width: trackWidth, color: secondaryTrackColor.cgColor, layer: cooldownLayer)
        
        drawIndicator(position: positionForValue(value: 0.0), color: indicatorColor.cgColor, layer: startIndicator)
        drawIndicator(position: positionForValue(value: countdown), color: indicatorColor.cgColor, layer: countdownIndicator)
        drawIndicator(position: positionForValue(value: primary + countdown), color: indicatorColor.cgColor, layer: primaryIndicator)
        
        if interval != nil {
            for i in 0..<intervalLayers.count {
                let intervalVal = interval! * Double(i + 1)
                if intervalVal != primary {
                    drawInterval(midpoint: positionForValue(value: intervalVal + countdown), value: intervalVal + countdown, color: UIColor.darkGray.cgColor, layer: intervalLayers[i])
                }
            }
        }
    }
    
    func createLabels() {
        timeLabel.frame = CGRect(x: 0, y: 0, width: bounds.width - 140, height: 50)
        timeLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2 - 16)
        timeLabel.textAlignment = .center
        timeLabel.font = timeLabel.font.withSize(56.0)
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.4
        timeLabel.text = "00:00:00"
        timeLabel.textColor = timerFontColor
        self.addSubview(timeLabel)
        
        descriptionLabel.frame = CGRect(x: 0, y: 0, width: bounds.width - 140, height: 25)
        descriptionLabel.center = CGPoint(x: bounds.width/2, y: (bounds.height/2) + (timeLabel.frame.height - 32))
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = timeLabel.font.withSize(18)
        descriptionLabel.textColor = descriptionFontColor
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.5
        descriptionLabel.text = "Meditation"
        self.addSubview(descriptionLabel)
    }
    
    // MARK: - Drawing Functions
    func drawTrack(startAngle: CGFloat, endAngle: CGFloat, width: Double, visible: Bool = false, color: CGColor, layer: CAShapeLayer) {
        let radius: CGFloat = min(bounds.size.width/2 - inset, bounds.size.height/2 - inset)
        let circleTrack = UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width/2, y: bounds.size.height/2),
            radius: CGFloat(radius - CGFloat(trackWidth / 2)),
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        
        layer.path = circleTrack.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color
        layer.lineWidth = CGFloat(width)
        layer.strokeEnd = visible ? 1.0 : 0.0
        layer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(layer)
        layer.setNeedsDisplay()
    }
    
    func drawInterval(midpoint: CGPoint?, value: Double, color: CGColor, layer: CAShapeLayer) {
        if let mid = midpoint {
            let path = UIBezierPath()
            var startPoint = CGPoint()
            var endPoint = CGPoint()
            
            let angle = valueToRadians(value)
            startPoint.x = mid.x + CGFloat((trackWidth/2) * cos(angle))
            startPoint.y = mid.y + CGFloat((trackWidth/2) * sin(angle))
            
            endPoint.x = mid.x + CGFloat((-trackWidth/2) * cos(angle))
            endPoint.y = mid.y + CGFloat((-trackWidth/2) * sin(angle))
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            layer.path = path.cgPath
            layer.fillColor = color
            layer.strokeColor = color
            layer.lineWidth = 2.0
            layer.lineCap = kCALineCapRound
            
            self.layer.addSublayer(layer)
            layer.setNeedsDisplay()
        }
    }
    
    func drawIndicator(position: CGPoint?, color: CGColor, layer: CAShapeLayer) {
        if let pos = position {
            let indicator = UIBezierPath(
                arcCenter: CGPoint(x: pos.x, y: pos.y),
                radius: CGFloat(indicatorRadius),
                startAngle: 0,
                endAngle: CGFloat(2 * M_PI),
                clockwise: true)
            layer.path = indicator.cgPath
            layer.fillColor = color
            
            self.layer.addSublayer(layer)
            layer.setNeedsDisplay()
        }
    }
    
    
    // MARK: - Animation Functions
    func beginAnimation() {
        started = true
        paused = false
        animateCircle(duration: countdown, beginTime: CACurrentMediaTime(), layer: countdownLayer, callback: nil)
        animateCircle(duration: primary, beginTime:  CACurrentMediaTime() + countdown, layer: primaryLayer, callback: nil)
        animateCircle(duration: cooldown, beginTime:  CACurrentMediaTime() + primary + countdown, layer: cooldownLayer, callback: nil)
    }
    
    func pauseAnimation() {
        paused = true
        let pausedTime = CACurrentMediaTime() - countdownLayer.beginTime
        
        countdownLayer.speed = 0.0
        countdownLayer.timeOffset = pausedTime
        
        primaryLayer.speed = 0.0
        primaryLayer.timeOffset = pausedTime
        
        cooldownLayer.speed = 0.0
        cooldownLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation() {
        paused = false
        let pausedTime = countdownLayer.timeOffset
        var timeSincePaused: CFTimeInterval
        
        countdownLayer.speed = 1.0
        countdownLayer.timeOffset = 0.0
        countdownLayer.beginTime = 0.0
        timeSincePaused = countdownLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        countdownLayer.beginTime = timeSincePaused
        
        primaryLayer.speed = 1.0
        primaryLayer.timeOffset = 0.0
        primaryLayer.beginTime = 0.0
        primaryLayer.beginTime = timeSincePaused
        
        cooldownLayer.speed = 1.0
        cooldownLayer.timeOffset = 0.0
        cooldownLayer.beginTime = 0.0
        cooldownLayer.beginTime = timeSincePaused
    }
    
    func clearAnimations() {
        started = false
        paused = false
        
        clearLayerAnimation(layer: countdownLayer)
        clearLayerAnimation(layer: primaryLayer)
        clearLayerAnimation(layer: cooldownLayer)
    }
    
    func clearLayerAnimation(layer: CAShapeLayer) {
        layer.removeAllAnimations()
        layer.speed = 1.0
        layer.timeOffset = 0.0
    }
    
    func animateCircle(duration: Double, beginTime: Double, layer: CAShapeLayer, callback: (() -> Void)?) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = beginTime
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: "linear")
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: "animateCircle")
    }
    
    //Label Functions
    func updateTimeLabel(with value: String) {
        timeLabel.text = value
    }
    
    func updateDescriptionLabel(with value: String) {
        descriptionLabel.text = value
    }
    
    
    // MARK: - Utilities
    func positionForValue(value: Double) -> CGPoint? {
        let r = valueToRadians(value)
        let radius = Double(bounds.size.width/2 - inset)
        let xCord = (radius - trackWidth/2) * cos(r) + Double(bounds.size.width/2)
        let yCord = (radius - trackWidth/2) * sin(r) + Double(bounds.size.height/2)
        
        return CGPoint(x: xCord, y: yCord)
    }
    
    //Converts a value to it's corresponding radian value as compared to total time
    func valueToRadians(_ value: Double) -> Double {
        let angle = (2 * M_PI) * (value / time)
        let translatedAngle = angle + degreeOfRotation
        return translatedAngle
    }
}