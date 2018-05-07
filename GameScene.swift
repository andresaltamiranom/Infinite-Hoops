//
//  GameScene.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/5/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    var viewController : UIViewController!
    let worldNode = SKNode()
    
    // Sprites
    let ball = SKSpriteNode(imageNamed: "ball")
    let court = SKSpriteNode(imageNamed: "court")
    let sound = SKSpriteNode(imageNamed: "sound")
    
    // Sounds
    let bgm = SKAudioNode(fileNamed: "Updown.mp3")
    let scoreSound = SKAudioNode(fileNamed: "goal.wav")
    let loseSound = SKAudioNode(fileNamed: "lose.wav")
    
    // Labels
    let tapToPauseAndRecalibrateLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let tapAnywhereToPlayLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let pausedLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    // Constant values
    let ballSpeed: Double = 25.0
    
    // Game Variables
    var canPlay = true
    var gameStarted = false
    var gameIsPaused = false
    var goalChance = true
    var soundIsOn = true
    var score: Int = 0
    var originalCourtSize = CGSize(width: 0, height: 0)
    var currentCourtIncreaseRate: CGFloat = 1.02
    
    var menuElements: [SKNode] = []
    var hoops: [(sprite: SKSpriteNode, attributes: (scale: CGFloat, positionRatio: (x: CGFloat, y: CGFloat)))] = []
    
    var motionManager = CMMotionManager()
    var referenceAttitude: CMAttitude?
    
    override func didMove(to view: SKView) {
        addChild(worldNode)
        self.backgroundColor = UIColor.init(hex: 0x2195d1)
        createLabels()
        createCourt()
        createBall()
        createSoundStuff()
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            motionManager.deviceMotionUpdateInterval = 0.05
        } else {
            canPlay = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if worldNode.isPaused {
                if gameStarted { // unpausing started game
                    pausedLabel.isHidden = true
                    calibrate()
                    worldNode.isPaused = false
                    gameIsPaused = false
                    bgm.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 0.0))
                } else { // game started but player has lost
                    // end game and go to result screen
                }
            } else {
                if !gameStarted {
                    if sound.contains(location) {
                        soundIsOn = !soundIsOn
                        sound.texture = soundIsOn ? SKTexture(imageNamed: "sound") : SKTexture(imageNamed: "mute")
                        UserDefaults.standard.set(soundIsOn, forKey: "sound")
                        bgm.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 1.0))
                    } else {
                        if !canPlay {
                            let alertView = UIAlertController(title: "Unable to play", message: "Device motion not available.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
                            alertView.addAction(action)
                            self.viewController.present(alertView, animated: true, completion: nil)
                        } else {
                            // start the game
                            gameStarted = true
                            calibrate()
                            
                            for element in menuElements {
                                element.removeFromParent()
                            }
                            
                            createHoops()
                            
                            scoreLabel.isHidden = false
                        }
                    }
                } else { // game is started - pause game
                    pausedLabel.isHidden = false
                    worldNode.isPaused = true
                    gameIsPaused = true
                    bgm.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameIsPaused && !worldNode.isPaused {
            worldNode.isPaused = true
        }
        
        guard !worldNode.isPaused else { return }
        
        if gameStarted {
            growCourt()
            growHoops()
            if ballIsAtGoal() {
                // Check if player scored hoop
                if goalChance {
                    
                } else {
                    
                }
                
                court.size = originalCourtSize
                createHoops()
                goalChance = true
            }
            
            updateBallMovement()
        }
    }
    
    func makeSureBallDoesntGoOutOfBounds(with moveToMake: CGVector) -> (Bool, Bool) {
        var willGoOutOfBoundsX = false
        if ball.leftmostPoint + moveToMake.dx < self.frame.minX {
            ball.position.x = self.frame.minX + ball.width * 0.5
            willGoOutOfBoundsX = true
        } else if ball.rightmostPoint + moveToMake.dx > self.frame.maxX {
            ball.position.x = self.frame.maxX - ball.width * 0.5
            willGoOutOfBoundsX = true
        }
        
        var willGoOutOfBoundsY = false
        if ball.bottomPoint + moveToMake.dy < self.frame.minY {
            ball.position.y = self.frame.minY + ball.height * 0.5
            willGoOutOfBoundsY = true
        } else if ball.topPoint + moveToMake.dy > self.frame.maxY {
            ball.position.y = self.frame.maxY - ball.height * 0.5
            willGoOutOfBoundsY = true
        }
        
        return (willGoOutOfBoundsX, willGoOutOfBoundsY)
    }
    
    func updateBallMovement() {
        var ballMovement = getMotionVector()
        let ballWillGoOut: (inX: Bool, inY: Bool) = makeSureBallDoesntGoOutOfBounds(with: ballMovement)
        
        if ballWillGoOut.inX { ballMovement.dx = 0 }
        if ballWillGoOut.inY { ballMovement.dy = 0 }
        
        ball.run(SKAction.move(by: ballMovement, duration: 0.05))
    }
    
    func growHoops() {
        for hoop in hoops {
            hoop.sprite.size = CGSize(width: court.height * hoop.attributes.scale, height: court.height * hoop.attributes.scale)
            hoop.sprite.position = CGPoint(x: court.leftmostPoint + court.width * hoop.attributes.positionRatio.x, y: court.bottomPoint + court.height * hoop.attributes.positionRatio.y)
        }
    }
    
    func growCourt() {
        court.size = CGSize(width: court.size.width * currentCourtIncreaseRate , height: court.size.height * currentCourtIncreaseRate)
    }
    
    func ballIsAtGoal() -> Bool {
        return court.topPoint > self.frame.maxY || court.bottomPoint < self.frame.minY
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
}
