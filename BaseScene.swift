//
//  BaseScene.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/17/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class BaseScene: SKScene {
    var viewController : UIViewController!
    let worldNode = SKNode()
    
    // Sprites
    let court = SKSpriteNode(imageNamed: "court")
    let ball = SKSpriteNode(imageNamed: "ball")
    
    // Sounds
    let scoreSound = SKAudioNode(fileNamed: "goal.wav")
    let missSound = SKAudioNode(fileNamed: "miss.mp3")
    
    // Constant values
    let ballSpeed: Double = 25.0
    let maxHoops = 5
    let basketsInARowToRegainHoop: Int = 10
    
    // Global Variables
    var canPlay = true
    var hoopsLeft: Int = 0
    var soundIsOn = true
    var currentCourtIncreaseRate: CGFloat = 1.02
    var hoops: [(sprite: SKSpriteNode, attributes: (direction: Directions, scale: CGFloat, positionRatio: (x: CGFloat, y: CGFloat)))] = []
    var motionManager = CMMotionManager()
    var referenceAttitude: CMAttitude?
    
    override func didMove(to view: SKView) {
        addChild(worldNode)
        self.backgroundColor = Config.bgColor
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            motionManager.deviceMotionUpdateInterval = 0.05
            
            hoopsLeft = maxHoops
        } else {
            canPlay = false
        }
    }
    
    func growCourt() {
        court.size = CGSize(width: court.size.width * currentCourtIncreaseRate , height: court.size.height * currentCourtIncreaseRate)
    }
    
    func growHoops() {
        for hoop in hoops {
            hoop.sprite.size = CGSize(width: court.height * hoop.attributes.scale, height: court.height * hoop.attributes.scale)
            hoop.sprite.position = CGPoint(x: court.leftmostPoint + court.width * hoop.attributes.positionRatio.x, y: court.bottomPoint + court.height * hoop.attributes.positionRatio.y)
        }
    }
    
    func updateBallMovement() {
        var ballMovement = getMotionVector()
        let ballWillGoOut: (inX: Bool, inY: Bool) = keepSpriteInRect(ball, in: self.frame, with: ballMovement)
        
        if ballWillGoOut.inX { ballMovement.dx = 0 }
        if ballWillGoOut.inY { ballMovement.dy = 0 }
        
        ball.run(SKAction.move(by: ballMovement, duration: 0.05))
    }
    
    func ballIsAtGoal() -> Bool {
        return court.topPoint > self.frame.maxY || court.bottomPoint < self.frame.minY
    }
    
    func scoredBasket() -> Bool {
        for hoop in hoops {
            if circleContainsCircle(hoop.sprite, ball) { return true }
        }
        return false
    }
    
    func calibrate() {
        referenceAttitude = motionManager.deviceMotion?.attitude.copy() as? CMAttitude
    }
    
    func getMotionVector() -> CGVector {
        let attitude = motionManager.deviceMotion?.attitude;
        
        // Use start orientation to calibrate
        attitude!.multiply(byInverseOf: referenceAttitude!)
        
        return CGVector(dx: attitude!.pitch * ballSpeed, dy: attitude!.roll  * ballSpeed)
    }
    
    func showCantPlayAlert() {
        let alertView = UIAlertController(title: "Unable to play", message: "Device motion not available.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
        alertView.addAction(action)
        self.viewController.present(alertView, animated: true, completion: nil)
    }
}
