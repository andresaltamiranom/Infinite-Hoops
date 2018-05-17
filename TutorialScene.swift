//
//  TutorialScene.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/17/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class TutorialScene: BaseScene {
    
    // Sound
    let tutorialBGM = SKAudioNode(fileNamed: "Updown.mp3")
    
    // Global variables
    var toldCantPlay = false
    var canMove = false
    var tutorial:
        (part1: (started: Bool, completed: Bool),
         part2: (started: Bool, completed: Bool),
         part3: (started: Bool, completed: Bool),
         part4: (started: Bool, completed: Bool)) =
        ((false, false), (false, false), (false, false), (false, false))
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        createSound()
        
        if canPlay {
            startTutorial(part: 1)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            if !canPlay {
                showCantPlayAlert()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !canPlay {
            if !toldCantPlay {
                showCantPlayAlert()
                toldCantPlay = true
            }
            return
        }
        
        if ball.parent != nil && canMove {
            updateBallMovement()
        }
        
        if tutorial.part1.completed {
            if movedBallFromInitialPosition() && !tutorial.part2.started {
                startTutorial(part: 2)
            }
            
            if tutorial.part2.completed {
                if !tutorial.part3.started {
                    growCourt()
                    growHoops()
                    
                    if ballIsAtGoal() {
                        if scoredBasket() {
                            scoreSound.run(SKAction.play())
                            stopPlaying()
                            startTutorial(part: 3)
                            return
                        } else {
                            missSound.run(SKAction.play())
                        }
                        
                        court.size = Config.court.originalSize
                        createHoops()
                    }
                }
                
                if tutorial.part3.completed && !tutorial.part4.started {
                    growCourt()
                    growHoops()
                    
                    if ballIsAtGoal() {
                        if scoredBasket() {
                            scoreSound.run(SKAction.play())
                        } else {
                            missSound.run(SKAction.play())
                            hoopsLeft -= 1
                            
                            if hoopsLeft == 0 {
                                stopPlaying()
                                startTutorial(part: 4)
                                return
                            }
                        }
                        
                        court.size = Config.court.originalSize
                        createHoops()
                    }
                }
            }
        }
    }
    
    func startTutorial(part: Int) {
        if part == 1 {
            self.run(SKAction.sequence([
                SKAction.run {
                    self.fadeLabel(message: "Welcome", fadeInDuration: 1.0, waitDuration: 1.5, fadeOutDuration: 1.0, labelSize: self.size.width / 12.5, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 4.0),
                SKAction.run {
                    self.fadeLabel(message: "Here's your ball", fadeInDuration: 1.0, waitDuration: 1.5, fadeOutDuration: 1.0, labelSize: self.size.width / 18.75, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 1.0),
                SKAction.run {
                    self.createBall(shouldFade: true)
                },
                SKAction.wait(forDuration: 3.0),
                SKAction.run {
                    self.fadeLabel(message: "Try tilting your device", fadeInDuration: 1.0, waitDuration: 1.5, fadeOutDuration: 1.0, labelSize: self.size.width / 18.75, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                    self.calibrate()
                    self.canMove = true
                },
                SKAction.wait(forDuration: 4.0),
                SKAction.run {
                    self.tutorial.part1.completed = true
                }])
            )
        } else if part == 2 {
            tutorial.part2.started = true
            self.run(SKAction.sequence([
                SKAction.run {
                    self.fadeLabel(message: "Good", fadeInDuration: 1.0, waitDuration: 1.0, fadeOutDuration: 1.0, labelSize: self.size.width / 12.5, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 3.5),
                SKAction.run {
                    self.fadeLabel(message: "Now let's try scoring a basket", fadeInDuration: 1.0, waitDuration: 1.5, fadeOutDuration: 1.0, labelSize: self.size.width / 18.75, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 4.0),
                SKAction.run {
                    self.createCourt(shouldFade: true)
                    self.createHoops(shouldFade: true)
                    self.tutorial.part2.completed = true
                }])
            )
        } else if part == 3 {
            tutorial.part3.started = true
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run {
                    self.fadeLabel(message: "Great!", fadeInDuration: 1.0, waitDuration: 1.0, fadeOutDuration: 1.0, labelSize: self.size.width / 12.5, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 3.5),
                SKAction.run {
                    self.fadeLabel(message: "Now let's see what happens when you miss", fadeInDuration: 1.0, waitDuration: 1.5, fadeOutDuration: 1.0, labelSize: self.size.width / 25, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 4.0),
                SKAction.run {
                    self.calibrate()
                    self.createBall(shouldFade: true)
                    self.ball.position = Config.ball.initialPosition
                    self.canMove = true
                    self.createCourt(shouldFade: true)
                    self.createHoops(shouldFade: true)
                    self.currentCourtIncreaseRate = 1.06
                    self.tutorial.part3.completed = true
                }])
            )
        } else if part == 4 {
            tutorial.part4.started = true
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run {
                    self.fadeLabel(message: "As you can see, you lose hoops when you miss!", fadeInDuration: 1.0, waitDuration: 3, fadeOutDuration: 1.0, labelSize: self.size.width / 25, xPos: self.size.width * 0.5, yPos: self.size.height * 0.55)
                    self.fadeLabel(message: "If you lose all the hoops, it's game over", fadeInDuration: 1.0, waitDuration: 3, fadeOutDuration: 1.0, labelSize: self.size.width / 25, xPos: self.size.width * 0.5, yPos: self.size.height * 0.45)
                },
                SKAction.wait(forDuration: 6.0),
                SKAction.run {
                    self.fadeLabel(message: "However, if you can score \(self.basketsInARowToRegainHoop) baskets in a row,", fadeInDuration: 1.0, waitDuration: 3.0, fadeOutDuration: 1.0, labelSize: self.size.width / 25, xPos: self.size.width * 0.5, yPos: self.size.height * 0.55)
                    self.fadeLabel(message: "you will recover a hoop, up to \(self.maxHoops).", fadeInDuration: 1.0, waitDuration: 3.0, fadeOutDuration: 1.0, labelSize: self.size.width / 25, xPos: self.size.width * 0.5, yPos: self.size.height * 0.45)
                },
                SKAction.wait(forDuration: 6.0),
                SKAction.run {
                    self.fadeLabel(message: "Now let's get to play!", fadeInDuration: 1.0, waitDuration: 1.5, fadeOutDuration: 1.0, labelSize: self.size.width / 18.75, xPos: self.size.width * 0.5, yPos: self.size.height * 0.5)
                },
                SKAction.wait(forDuration: 4.0),
                SKAction.run {
                    UserDefaults.standard.set(true, forKey: "completedTutorial")
                    
                    self.removeAllActions()
                    self.removeAllChildren()
                    
                    let newScene = GameScene(size: self.size)
                    newScene.scaleMode = self.scaleMode
                    self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 2.0))
                    newScene.viewController = self.viewController
                }])
            )
        }
    }
    
    func fadeLabel(message: String, fadeInDuration: TimeInterval, waitDuration: TimeInterval, fadeOutDuration: TimeInterval, labelSize: CGFloat, xPos: CGFloat, yPos: CGFloat) {
        
        let label = createLabel(
            text: message,
            fontSize: labelSize,
            xPos: xPos,
            yPos: yPos)
        label.alpha = 0
        addChild(label)
        
        label.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeInDuration),
            SKAction.wait(forDuration: waitDuration),
            SKAction.fadeOut(withDuration: fadeOutDuration),
            SKAction.run {
                label.removeFromParent()
            }])
        )
    }
    
    func stopPlaying() {
        fadeAndRemove(node: ball)
        fadeAndRemove(node: court)
        for hoop in hoops {
            fadeAndRemove(node: hoop.sprite)
        }
        hoops.removeAll()
        canMove = false
    }
}
