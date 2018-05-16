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
        let dunkTheBallLabel = createLabel(
            text: "Dunk the ball inside any of the hoops to score.",
            fontSize: size.width / 37.5,
            xPos: size.width * 0.5,
            yPos: size.height * 0.66)
        
        let highscoreLabel = createLabel(
            text: "Highscore: \(UserDefaults.standard.integer(forKey: "highscore"))",
            horizontalAlignment: .right,
            fontSize: size.width / 25,
            xPos: size.width * 0.985,
            yPos: size.height * 0.9)
        
        let tapAnywhereToPlayLabel = createLabel(
            text: "Tap to start playing!",
            fontSize: size.width / 25,
            xPos: size.width * 0.5,
            yPos: size.height * 0.3)
        
        let tapToPauseAndRecalibrateLabel = createLabel(
            text: "Once the game starts, tap to pause and recalibrate.",
            fontSize: size.width / 37.5,
            xPos: size.width * 0.5,
            yPos: size.height * 0.73)
        
        let tiltToMoveLabel = createLabel(
            text: "Tilt your device to move the ball.",
            fontSize: size.width / 37.5,
            xPos: size.width * 0.5,
            yPos: size.height * 0.8)
        
        pausedLabel = createLabel(
            text: "Paused",
            horizontalAlignment: .left,
            fontSize: size.width / 18.75,
            xPos: size.width * 0.015,
            yPos: size.height * 0.9,
            isHidden: true,
            zPosition: 10)
        
        scoreLabel = createLabel(
            text: "Score: \(score)",
            horizontalAlignment: .right,
            fontSize: size.width / 18.75,
            xPos: size.width * 0.985,
            yPos: size.height * 0.9,
            isHidden: true,
            zPosition: 10)
        
        menuElements += [dunkTheBallLabel,
                         highscoreLabel,
                         tapAnywhereToPlayLabel,
                         tapToPauseAndRecalibrateLabel,
                         tiltToMoveLabel]
        
        addChild(dunkTheBallLabel)
        addChild(highscoreLabel)
        addChild(tapAnywhereToPlayLabel)
        addChild(tapToPauseAndRecalibrateLabel)
        addChild(tiltToMoveLabel)
        addChild(pausedLabel)
        addChild(scoreLabel)
    }
    
    func createMenuShareButton() {
        shareButton.size = sound.size
        shareButton.position = CGPoint(x: sound.position.x, y: sound.position.y - shareButton.height - size.height * 0.05)
        menuElements.append(shareButton)
        addChild(shareButton)
    }
    
    func createShareButton() {
        shareButton.size = CGSize(width: size.width * 0.1, height: size.width * 0.1)
        shareButton.position = CGPoint(x: size.width * 0.985 - shareButton.width * 0.5, y: size.height * 0.985 - shareButton.height * 0.5)
        addChild(shareButton)
        
        let shareButtonText = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        shareButtonText.text = "SHARE"
        shareButtonText.fontColor = SKColor.black
        shareButtonText.horizontalAlignmentMode = .center
        shareButtonText.fontSize = size.width / 37.5
        shareButtonText.position = CGPoint(x: shareButton.position.x, y: shareButton.position.y - shareButton.height * 0.5 - shareButtonText.frame.height)
        addChild(shareButtonText)
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
            hoop.sprite.removeFromParent()
        }
        hoops.removeAll()
        for _ in 1...hoopsLeft {
            let newHoop = SKSpriteNode(imageNamed: "hoop")
            let hoopScale = random(min: 0.23, max: 0.32)
            newHoop.size = CGSize(width: court.height * hoopScale, height: court.height * hoopScale)
            
            var hoopsIntersect = false
            repeat {
                hoopsIntersect = false
                newHoop.position = CGPoint(x: random(min: court.leftmostPoint + newHoop.width * 0.5, max: court.rightmostPoint - newHoop.width * 0.5), y: random(min: court.bottomPoint + newHoop.height * 0.5, max: court.topPoint - newHoop.height * 0.5))
                for hoop in hoops {
                    if circleIntersectsCircle(newHoop, hoop.sprite) || circleContainsCircle(newHoop, hoop.sprite) {
                        hoopsIntersect = true
                        break
                    }
                }
            } while hoopsIntersect
            
            let hoopPositionRatio = ((newHoop.position.x - court.leftmostPoint) / court.width, (newHoop.position.y - court.bottomPoint) / court.height)
            
            newHoop.zPosition = 2
            hoops.append((newHoop, (Directions.randomDirection(), hoopScale, hoopPositionRatio)))
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
