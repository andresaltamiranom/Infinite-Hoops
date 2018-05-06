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
    
    func createCourt() {
        court.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
        originalCourtSize = court.size
        court.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        court.zPosition = 1
        worldNode.addChild(court)
    }
    
    func createBall() {
        ball.size = CGSize(width: size.height * 0.15, height: size.height * 0.15) // same dimensions to keep ball round
        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
        ball.zPosition = 10
        
        worldNode.addChild(ball)
    }
}
