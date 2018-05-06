//
//  GameScene.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/5/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var viewController : UIViewController!
    
    let worldNode = SKNode()
    
    var gameStarted = false
    
    var menuElements: [SKNode] = []
    
    // Sprites
    let ball = SKSpriteNode(imageNamed: "ball")
    
    // Labels
    let tapToPauseAndRecalibrateLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    let tapAnywhereToPlayLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    override func didMove(to view: SKView) {
        addChild(worldNode)
        self.backgroundColor = UIColor.init(hex: 0x2195d1)
        createLabels()
        createBall()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if !gameStarted {
                // start the game
                gameStarted = true
                
                for element in menuElements {
                    element.removeFromParent()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
