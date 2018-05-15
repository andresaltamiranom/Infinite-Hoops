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
    let shareButton = SKSpriteNode(imageNamed: "share_button")
    let sound = SKSpriteNode(imageNamed: "sound")
    
    // Labels
    var pausedLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    
    // Sounds
    let bgm = SKAudioNode(fileNamed: "Updown.mp3")
    let loseSound = SKAudioNode(fileNamed: "lose.wav")
    let scoreSound = SKAudioNode(fileNamed: "goal.wav")
    
    // Constant values
    let ballSpeed: Double = 25.0
    let bgColor = UIColor.init(hex: 0x2195d1)
    
    // Game Variables
    var canPlay = true
    var gameStarted = false
    var gameIsPaused = false
    var finishedGame = false
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
        self.backgroundColor = bgColor
        createLabels()
        createCourt()
        createBall()
        createSoundStuff()
        createMenuShareButton()
        
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
            
            if finishedGame {
                if shareButton.contains(location) {
                    let textToShare = "I just scored \(score) \(score == 1 ? "basket" : "baskets") on Infinite Hoops! Try to beat me, it's free! #InfiniteHoops"
                    
                    let objectsToShare = [textToShare]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                    
                    if let popOver = activityVC.popoverPresentationController {
                        popOver.sourceView = self.viewController.view
                        popOver.sourceRect = self.viewController.view.bounds
                    }
                    
                    self.viewController.present(activityVC, animated: true, completion: nil)
                } else {
                    exitGame() // goes back to main menu screen
                }
            } else if worldNode.isPaused {
                if gameStarted { // unpausing started game
                    pausedLabel.isHidden = true
                    calibrate()
                    worldNode.isPaused = false
                    gameIsPaused = false
                    bgm.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 0.0))
                } else { // game started but player has lost
                    endGame() // goes to results screen
                }
            } else {
                if !gameStarted {
                    if sound.contains(location) {
                        soundIsOn = !soundIsOn
                        sound.texture = soundIsOn ? SKTexture(imageNamed: "sound") : SKTexture(imageNamed: "mute")
                        UserDefaults.standard.set(soundIsOn, forKey: "sound")
                        bgm.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 1.0))
                    } else if shareButton.contains(location) {
                        let hs = UserDefaults.standard.integer(forKey: "highscore")
                        let textToShare = "Can you beat my highscore of \(hs) \(hs == 1 ? "basket" : "baskets") on Infinite Hoops? Come try, it's free! #InfiniteHoops"
                        
                        let objectsToShare = [textToShare]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                        
                        if let popOver = activityVC.popoverPresentationController {
                            popOver.sourceView = self.viewController.view
                            popOver.sourceRect = self.viewController.view.bounds
                        }
                        
                        self.viewController.present(activityVC, animated: true, completion: nil)
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
                if scoredBasket() {
                    score = score + 1
                    scoreLabel.text = "Score: \(score)"
                    
                    if soundIsOn {
                        scoreSound.run(SKAction.play())
                    }
                } else {
                    self.backgroundColor = UIColor.init(hex: 0xf92020)
                    
                    gameStarted = false
                    if soundIsOn {
                        loseSound.run(SKAction.play())
                    }
                    
                    worldNode.isPaused = true
                    return
                }
                
                court.size = originalCourtSize
                createHoops()
            }
            
            updateBallMovement()
        }
    }
    
    func scoredBasket() -> Bool {
        for hoop in hoops {
            if circleContainsCircle(hoop.sprite, ball) { return true }
        }
        return false
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
    
    func endGame() {
        self.backgroundColor = bgColor
        
        finishedGame = true
        
        worldNode.removeAllActions()
        worldNode.removeAllChildren()
        scoreLabel.removeFromParent()
        pausedLabel.removeFromParent()
        
        let beatHighscore = checkForHighscore()
        
        let finalScoreMessageLabel = createLabel(text: "", fontSize: size.width / 25, xPos: size.width * 0.5, yPos: size.height * 0.2)
        
        if score == 0 {
            finalScoreMessageLabel.text = "You scored 0 baskets :("
        } else if beatHighscore {
            if score == 1 {
                finalScoreMessageLabel.text = "New highscore! You scored 1 basket! :D"
            } else {
                finalScoreMessageLabel.text = "New highscore! You scored \(score) baskets! :D"
            }
        } else if score == 1 {
            finalScoreMessageLabel.text = "You scored 1 basket :|"
        } else {
            finalScoreMessageLabel.text = "You scored \(score) baskets! :)"
        }
        
        addChild(finalScoreMessageLabel)
        
        let goBackLabel = createLabel(text: "Tap screen to go back", fontSize: size.width / 37.5, xPos: size.width * 0.5, yPos: size.height * 0.1)
        addChild(goBackLabel)
        
        createShareButton()
    }
    
    func exitGame() {
        self.removeAllActions()
        self.removeAllChildren()
        
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 1.0))
        newScene.viewController = self.viewController
    }
}
