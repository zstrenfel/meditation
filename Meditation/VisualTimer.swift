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
            updateValues()
        }
    }
    
    var started: Bool = false
    var paused: Bool = false
    var countdown: Double = 0.0
    var primary: Double = 0.0
    var cooldown: Double = 0.0
    var time: Double = 0.0
    
    var interval: Double = 0.0
    var intervalRepeat: Bool = true
    
    var displayTime: Bool = true 
    //Visual Design Variables
    
    //Colors
    @IBInspectable var baseTrackColor: UIColor = ColorPalette.gray.light
    @IBInspectable var primaryTrackColor: UIColor = ColorPalette.gray.dark
    @IBInspectable var secondaryTrackColor: UIColor = ColorPalette.gray.medium
    @IBInspectable var indicatorColor: UIColor = ColorPalette.blue.light
    @IBInspectable var primaryIndicatorColor: UIColor = ColorPalette.pink.primary
    
    @IBInspectable var intervalColor: UIColor = UIColor.lightGray
    @IBInspectable var timerFontColor: UIColor = ColorPalette.gray.dark
    @IBInspectable var descriptionFontColor: UIColor = ColorPalette.gray.medium
    @IBInspectable var timerFontSize: Double = 28.0
    @IBInspectable var descriptionFontSize: Double = 18.0
    @IBInspectable var topLabelBuffer: Double = 16.0
    @IBInspectable var middleLabelBuffer: Double = 24.0
    
    
    var inset: CGFloat = 8.0
    var trackWidth: Double = 12.0
    var degreeOfRotation: Double = Double.pi / 2
    
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
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.addSublayer(baseTrackLayer)
        layer.addSublayer(countdownLayer)
        layer.addSublayer(primaryLayer)
        layer.addSublayer(cooldownLayer)
        layer.addSublayer(startIndicator)
        layer.addSublayer(countdownIndicator)
        layer.addSublayer(primaryIndicator)
        
        self.addSubview(timeLabel)
        self.addSubview(descriptionLabel)
        
        updateLabels()
        updateLayerFrames()
    }
    
    func updateTimer(with timer: MeditationTimer) {
        self.timer = timer
    }
    
    func updateValues() {
        if let t = timer {
            self.countdown = t.countdown
            self.primary = t.primary
            self.cooldown = t.cooldown
            self.time = countdown + primary + cooldown
            self.displayTime = t.display_time
            
            if (intervalLayers.count == 0 && t.interval > 0.0) ||
                interval != t.interval ||
                intervalRepeat != t.interval_repeat {
                self.interval = t.interval
                self.intervalRepeat = t.interval_repeat
                
                intervalLayers.forEach { $0.removeFromSuperlayer() }
                intervalLayers = []
                createIntervalLayers()
            }
            
            updateLabels()
            updateLayerFrames()
        }
        
    }
    
    func createIntervalLayers() {
        if interval > 0.0 {
            let intervalCount = !intervalRepeat ? 1 : Int(floor(primary/interval))
            for _ in 0..<intervalCount {
                let intervalLayer = CAShapeLayer()
                intervalLayers.append(intervalLayer)
            }
        }
    }

    func updateLayerFrames() {
        drawTrack(startAngle: 0.0, endAngle: CGFloat(2 * Double.pi), width: trackWidth + 6.0, strokeEnd: 1.0, color: baseTrackColor.cgColor, layer: baseTrackLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(0.0)), endAngle:  CGFloat(valueToRadians(countdown)), width: trackWidth, color: secondaryTrackColor.cgColor, layer: countdownLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(countdown)), endAngle:  CGFloat(valueToRadians(primary + countdown)), width: trackWidth, color: primaryTrackColor.cgColor, layer: primaryLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(primary + countdown)), endAngle:  CGFloat(valueToRadians(time)), width: trackWidth, color: secondaryTrackColor.cgColor, layer: cooldownLayer)
        
        drawIndicator(position: positionForValue(value: 0.0), color: primaryIndicatorColor.cgColor, layer: startIndicator)
        drawIndicator(position: positionForValue(value: countdown), color: indicatorColor.cgColor, layer: countdownIndicator)
        drawIndicator(position: positionForValue(value: primary + countdown), color: indicatorColor.cgColor, layer: primaryIndicator)
        
        for i in 0..<intervalLayers.count {
            let intervalVal = interval * Double(i + 1)
            if intervalVal != primary {
                drawInterval(midpoint: positionForValue(value: intervalVal + countdown), value: intervalVal + countdown, color: intervalColor.cgColor, layer: intervalLayers[i])
            }
        }
    }
    
    
    func updateLabels() {
        timeLabel.frame = CGRect(x: 0, y: 0, width: bounds.width - 100, height: CGFloat(timerFontSize + 10))
        timeLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2 - CGFloat(topLabelBuffer))
        timeLabel.textAlignment = .center
        timeLabel.font = timeLabel.font.withSize(CGFloat(timerFontSize))
        timeLabel.textColor = timerFontColor
        timeLabel.text = time.timeString
        timeLabel.isHidden = !displayTime
        
        
        descriptionLabel.frame = CGRect(x: 0, y: 0, width: bounds.width - 140, height: 25)
        
        //dependent on whether time is visible or not
        let yValue = displayTime ? (bounds.height/2) + CGFloat(timerFontSize - middleLabelBuffer) : (bounds.height/2 - CGFloat(topLabelBuffer))
        
        descriptionLabel.center = CGPoint(x: bounds.width/2, y: yValue)
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = timeLabel.font.withSize(CGFloat(descriptionFontSize))
        descriptionLabel.textColor = descriptionFontColor
        descriptionLabel.text = "Meditation"
        
    }
    
    func showTimeLabel() {
        timeLabel.isHidden = false
        descriptionLabel.center = CGPoint(x: bounds.width/2, y: (bounds.height/2) + CGFloat(timerFontSize - middleLabelBuffer))
    }
    
    func hideTimeLabel() {
        timeLabel.isHidden = true
        descriptionLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2 - CGFloat(topLabelBuffer))
    }
    
    
    func setTime(with time: Double, animate: Bool) {
        log.debug("beginning animations from \(time)")
        let countdownStrokeEnd = (time / countdown) >= 1 ? 1.0 : (time / countdown)
        let primaryStrokeEnd = countdownStrokeEnd == 1.0  ? (time - countdown) / primary : 0.0
        let cooldownStrokeEnd = primaryStrokeEnd == 1.0 ? (time - countdown - primary) / cooldown : 0.0
        
        drawTrack(startAngle: CGFloat(valueToRadians(0.0)), endAngle:  CGFloat(valueToRadians(countdown)), width: trackWidth, strokeEnd: countdownStrokeEnd, color: secondaryTrackColor.cgColor, layer: countdownLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(countdown)), endAngle:  CGFloat(valueToRadians(primary + countdown)), width: trackWidth, strokeEnd: primaryStrokeEnd,  color: primaryTrackColor.cgColor, layer: primaryLayer)
        drawTrack(startAngle: CGFloat(valueToRadians(primary + countdown)), endAngle:  CGFloat(valueToRadians(time)), width: trackWidth, strokeEnd: cooldownStrokeEnd, color: secondaryTrackColor.cgColor, layer: cooldownLayer)
        
        if animate {
            beginAnimation(from: time)
        }
    }
    
    // MARK: - Drawing Functions
    func drawTrack(startAngle: CGFloat, endAngle: CGFloat, width: Double, strokeEnd: Double = 0.0, color: CGColor, layer: CAShapeLayer) {
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
        layer.strokeEnd = CGFloat(strokeEnd)
        layer.lineCap = kCALineCapRound
        
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
                endAngle: CGFloat(2 * Double.pi),
                clockwise: true)
            layer.path = indicator.cgPath
            layer.fillColor = color
            
            layer.setNeedsDisplay()
        }
    }
    
    
    // MARK: - Animation Functions
    func beginAnimation() {
        log.debug("beginning animations")
        started = true
        paused = false
        
        clearAnimations()
        
        animateCircle(duration: countdown, delay: 0.0, layer: countdownLayer, callback: nil)
        animateCircle(duration: primary, delay:  countdown, layer: primaryLayer, callback: nil)
        animateCircle(duration: cooldown, delay: primary + countdown, layer: cooldownLayer, callback: nil)
    }
    
    func beginAnimation(from time: Double) {
        let countdownCompleted = (time / countdown) >= 1 ? true : false
        let primaryCompleted = (time - countdown) / primary >= 1 ? true : false
        let cooldownCompleted = (time - countdown - primary) / cooldown >= 1 ? true : false
        
        var primaryDuration = 0.0
        var cooldownDuration = 0.0
        var countdownDuration = 0.0
        
        if !countdownCompleted {
            countdownDuration = countdown * (countdown / time)
            animateCircle(duration: countdownDuration, delay: 0.0, layer: countdownLayer, callback: nil)
        }
        
        if !primaryCompleted {
            primaryDuration = primary * (primary / (time - countdown))
            animateCircle(duration: primaryDuration, delay: countdownDuration, layer: primaryLayer, callback: nil)
        }
        
        if !cooldownCompleted {
            cooldownDuration = cooldown * (cooldown / (time - primary - countdown))
            animateCircle(duration: cooldownDuration, delay: countdownDuration + primaryDuration, layer: cooldownLayer, callback: nil)
        }
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
    
    func clearVisualTimer() {
        started = false
        paused = false
        updateTimeLabel(with: self.time.timeString)
        updateDescriptionLabel(with: "Meditation")
        clearAnimations()
    }
    
    func clearAnimations() {
        clearLayerAnimation(layer: countdownLayer)
        clearLayerAnimation(layer: primaryLayer)
        clearLayerAnimation(layer: cooldownLayer)
    }
    
    func clearLayerAnimation(layer: CAShapeLayer) {
        layer.removeAllAnimations()
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.needsLayout()
    }
    
    func animateCircle(duration: Double, delay: Double, layer: CAShapeLayer, callback: (() -> Void)?) {
        let syncTime = layer.convertTime(CACurrentMediaTime(), from: self.layer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = syncTime + delay
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: "linear")
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: "animateCircle")
    }
    
    func animationsActive() -> Bool {
        //countdown is the last one to run
        return countdownLayer.animationKeys() != nil
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
        
        if xCord.isNaN || yCord.isNaN {
            return nil
        }
        return CGPoint(x: xCord, y: yCord)
    }
    
    //Converts a value to it's corresponding radian value as compared to total time
    func valueToRadians(_ value: Double) -> Double {
        let angle = (2 * Double.pi) * (value / time)
        let translatedAngle = angle + degreeOfRotation
        return translatedAngle
    }
}
