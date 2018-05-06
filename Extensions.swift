//
//  Extensions.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/6/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import Foundation
import SpriteKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension SKSpriteNode {
    var width:  CGFloat { return self.size.width }
    var height: CGFloat { return self.size.height }
    
    var rightmostPoint: CGFloat { return self.position.x + self.width * 0.5 }
    var leftmostPoint:  CGFloat { return self.position.x - self.width * 0.5 }
    var topPoint:       CGFloat { return self.position.y + self.height * 0.5 }
    var bottomPoint:    CGFloat { return self.position.y - self.height * 0.5 }
    
    override open func contains(_ point: CGPoint) -> Bool {
        return self.frame.contains(point)
    }
}

extension SKShapeNode {
    var width:  CGFloat { return self.frame.width }
    var height: CGFloat { return self.frame.height }
}

extension GameScene {
    func collided(body1: UInt32, body2: UInt32, contact: SKPhysicsContact) -> Bool {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        return (firstBody.categoryBitMask == body1 && secondBody.categoryBitMask == body2) ||
            (firstBody.categoryBitMask == body2 && secondBody.categoryBitMask == body1)
    }
    
    // Checks whether a circle intersects with another circle
    func circleIntersectsCircle(_ circle1: SKSpriteNode, _ circle2: SKSpriteNode) -> Bool {
        let x0 = circle1.position.x
        let y0 = circle1.position.y
        let r0 = circle1.height * 0.5
        let x1 = circle2.position.x
        let y1 = circle2.position.y
        let r1 = circle2.height * 0.5
        let midCalc = pow(x0 - x1, 2) + pow(y0 - y1, 2)
        
        return pow(r0 - r1, 2) <= midCalc && midCalc <= pow(r0 + r1, 2)
    }
    
    fileprivate func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
}
