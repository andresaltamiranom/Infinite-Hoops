//
//  Creates.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/6/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
    func createLabels() {
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontColor = SKColor.black
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontSize = size.width / 18.75
        scoreLabel.position = CGPoint(x: size.width * 0.985, y: size.height * 0.9)
        scoreLabel.zPosition = 10
        scoreLabel.isHidden = true
        addChild(scoreLabel)
        
        pausedLabel.text = "Paused"
        pausedLabel.fontColor = SKColor.black
        pausedLabel.horizontalAlignmentMode = .left
        pausedLabel.fontSize = scoreLabel.fontSize
        pausedLabel.position = CGPoint(x: size.width * 0.015, y: scoreLabel.position.y)
        pausedLabel.zPosition = 10
        pausedLabel.isHidden = true
        addChild(pausedLabel)
        
        tapAnywhereToPlayLabel.text = "Tap screen to play!"
        tapAnywhereToPlayLabel.fontColor = SKColor.black
        tapAnywhereToPlayLabel.horizontalAlignmentMode = .center
        tapAnywhereToPlayLabel.fontSize = size.width / 25
        tapAnywhereToPlayLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        tapAnywhereToPlayLabel.isHidden = false
        menuElements.append(tapAnywhereToPlayLabel)
        addChild(tapAnywhereToPlayLabel)
        
        tapToPauseAndRecalibrateLabel.text = "Once the game starts, tap to pause and recalibrate"
        tapToPauseAndRecalibrateLabel.fontColor = SKColor.black
        tapToPauseAndRecalibrateLabel.horizontalAlignmentMode = .center
        tapToPauseAndRecalibrateLabel.fontSize = size.width / 37.5
        tapToPauseAndRecalibrateLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.6)
        tapToPauseAndRecalibrateLabel.isHidden = false
        menuElements.append(tapToPauseAndRecalibrateLabel)
        addChild(tapToPauseAndRecalibrateLabel)
    }
    
    func createSoundStuff() {
        soundIsOn = UserDefaults.standard.bool(forKey: "sound")
        
        sound.size = CGSize(width: size.width * 0.065, height: size.width * 0.065)
        sound.position = CGPoint(x: size.width * 0.05, y: size.height * 0.9 + sound.height * 0.2)
        sound.texture = soundIsOn ? SKTexture(imageNamed: "sound") : SKTexture(imageNamed: "mute")
        
        bgm.name = "bgm"
        bgm.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 0.0))
        scoreSound.run(SKAction.changeVolume(to: soundIsOn ? 1.0 : 0.0, duration: 0.0))
        loseSound.run(SKAction.changeVolume(to: soundIsOn ? 1.0 : 0.0, duration: 0.0))
        
        bgm.autoplayLooped = true
        scoreSound.autoplayLooped = false
        loseSound.autoplayLooped = false
        
        menuElements.append(sound)
        
        addChild(bgm)
        addChild(sound)
        addChild(scoreSound)
        addChild(loseSound)
    }
    
    func createCourt() {
        court.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
        originalCourtSize = court.size
        court.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        court.zPosition = 1
        worldNode.addChild(court)
    }
    
    func createHoops() {
        for hoop in hoops {
            hoop.removeFromParent()
        }
        hoops.removeAll()
        for _ in 1...5 {
            let newHoop = SKSpriteNode(imageNamed: "hoop")
            let diameter = size.height * random(min: 0.25, max: 0.35)
            newHoop.size = CGSize(width: diameter, height: diameter)
            
            var hoopsIntersect = false
            repeat {
                hoopsIntersect = false
                newHoop.position = CGPoint(x: random(min: self.frame.minX + newHoop.width * 0.5, max: self.frame.maxX - newHoop.width * 0.5), y: random(min: self.frame.minY + newHoop.height * 0.5, max: self.frame.maxY - newHoop.height * 0.5))
                for hoop in hoops {
                    if circleIntersectsCircle(newHoop, hoop) {
                        hoopsIntersect = true
                        break
                    }
                }
            } while hoopsIntersect
            
            newHoop.zPosition = 2
            hoops.append(newHoop)
            worldNode.addChild(newHoop)
        }
    }
    
    func createBall() {
        ball.size = CGSize(width: size.height * 0.15, height: size.height * 0.15) // same dimensions to keep ball round
        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
        ball.zPosition = 10
        
        worldNode.addChild(ball)
    }
}
