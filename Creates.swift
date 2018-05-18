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
        
        menuElements += [highscoreLabel,
                         tapAnywhereToPlayLabel,
                         tapToPauseAndRecalibrateLabel]
        
        addChild(highscoreLabel)
        addChild(tapAnywhereToPlayLabel)
        addChild(tapToPauseAndRecalibrateLabel)
        addChild(pausedLabel)
        addChild(scoreLabel)
    }
    
    func createShareButton(inMenu: Bool = false) {
        if inMenu {
            shareButton.size = Config.menuButton.size
            shareButton.position = Config.menuButton.positions[1]
            menuElements.append(shareButton)
        } else {
            shareButton.size = Config.shareButton.size
            shareButton.position = Config.shareButton.position
            
            let shareButtonText = createLabel(text: "SHARE", fontSize: size.width / 37.5, xPos: 0, yPos: 0)
            shareButtonText.position = CGPoint(x: shareButton.position.x, y: shareButton.position.y - shareButton.height * 0.5 - shareButtonText.frame.height)
            addChild(shareButtonText)
        }
        addChild(shareButton)
    }
    
    func createSound() {
        super.createBaseSound()
        
        soundButton.size = Config.menuButton.size
        soundButton.position = Config.menuButton.positions[0]
        soundButton.texture = soundIsOn ? SKTexture(imageNamed: "sound") : SKTexture(imageNamed: "mute")
        
        loseSound.run(SKAction.changeVolume(to: soundIsOn ? 1.0 : 0.0, duration: 0.0))
        loseSound.autoplayLooped = false
        
        menuElements.append(soundButton)
        
        addChild(soundButton)
        addChild(loseSound)
    }
    
    func createNoAdsButton() {
        noAds.size = Config.menuButton.size
        noAds.position = Config.menuButton.positions[2]
        menuElements.append(noAds)
        addChild(noAds)
    }
    
    func createBuyNoAdsBanner() {
        bannerBackground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        bannerBackground.position = CGPoint(x: 0, y: 0)
        bannerBackground.fillColor = SKColor.gray
        bannerBackground.strokeColor = SKColor.black
        bannerBackground.zPosition = 20
        addChild(bannerBackground)
        
        noAdsLabel = createLabel(
            text: "Remove ads by selecting",
            fontColor: SKColor.white,
            fontSize: size.width / 25,
            xPos: size.width * 0.5,
            yPos: size.height * 0.5,
            zPosition: 21)
        
        noAdsLabel2 = createLabel(
            text: "the option in the main menu!",
            fontColor: SKColor.white,
            fontSize: size.width / 25,
            xPos: size.width * 0.5,
            yPos: size.height * 0.4,
            zPosition: 21)
        
        addChild(noAdsLabel)
        addChild(noAdsLabel2)
        
        closeBannerButton.size = CGSize(width: size.width * 0.06, height: size.width * 0.06)
        closeBannerButton.position = CGPoint(x: size.height * 0.1, y: size.height * 0.9)
        closeBannerButton.zPosition = 21
        
        addChild(closeBannerButton)
    }
}

extension TutorialScene {
    func createSound() {
        super.createBaseSound()
    }
}

extension BaseScene {
    func createBaseSound() {
        soundIsOn = UserDefaults.standard.bool(forKey: "sound")
        
        gameBGM.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 0.0))
        scoreSound.run(SKAction.changeVolume(to: soundIsOn ? 1.0 : 0.0, duration: 0.0))
        missSound.run(SKAction.changeVolume(to: soundIsOn ? 1.0 : 0.0, duration: 0.0))
        
        gameBGM.autoplayLooped = true
        scoreSound.autoplayLooped = false
        missSound.autoplayLooped = false
        
        addChild(gameBGM)
        addChild(scoreSound)
        addChild(missSound)
    }
    
    func createCourt(shouldFade: Bool = false) {
        court.size = Config.court.originalSize
        court.position = Config.court.position
        court.zPosition = 1
        
        addNode(node: court, fade: shouldFade)
    }
    
    func createHoops(shouldFade: Bool = false) {
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
            
            addNode(node: newHoop, fade: shouldFade)
        }
    }
    
    func createBall(shouldFade: Bool = false) {
        ball.size = Config.ball.size
        ball.position = Config.ball.initialPosition
        ball.zPosition = 10
        
        addNode(node: ball, fade: shouldFade)
    }
}
