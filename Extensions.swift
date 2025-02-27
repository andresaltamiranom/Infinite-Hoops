//
//  Extensions.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/6/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

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

extension BaseScene {
    func addNode(node: SKNode, fade: Bool = false) {
        if fade {
            node.alpha = 0
            worldNode.addChild(node)
            node.run(SKAction.fadeIn(withDuration: 1.0))
        } else {
            worldNode.addChild(node)
        }
    }
    
    func keepSpriteInRect(_ sprite: SKSpriteNode, in container: CGRect, with moveToMake: CGVector) -> (Bool, Bool) {
        var willGoOutOfBoundsX = false
        if sprite.leftmostPoint + moveToMake.dx < container.minX {
            sprite.position.x = container.minX + sprite.width * 0.5
            willGoOutOfBoundsX = true
        } else if sprite.rightmostPoint + moveToMake.dx > container.maxX {
            sprite.position.x = container.maxX - sprite.width * 0.5
            willGoOutOfBoundsX = true
        }
        
        var willGoOutOfBoundsY = false
        if sprite.bottomPoint + moveToMake.dy < container.minY {
            sprite.position.y = container.minY + sprite.height * 0.5
            willGoOutOfBoundsY = true
        } else if sprite.topPoint + moveToMake.dy > container.maxY {
            sprite.position.y = container.maxY - sprite.height * 0.5
            willGoOutOfBoundsY = true
        }
        
        return (willGoOutOfBoundsX, willGoOutOfBoundsY)
    }
}

extension SKScene {
    func createLabel(font: String = Config.defaultFont, text: String, fontColor: SKColor = Config.defaultFontColor, horizontalAlignment: SKLabelHorizontalAlignmentMode = .center, verticalAlignment: SKLabelVerticalAlignmentMode = .baseline, fontSize: CGFloat, xPos: CGFloat, yPos: CGFloat, isHidden: Bool = false, zPosition: CGFloat = 0) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: font)
        label.text = text
        label.fontColor = fontColor
        label.horizontalAlignmentMode = horizontalAlignment
        label.verticalAlignmentMode = verticalAlignment
        label.fontSize = fontSize
        label.position = CGPoint(x: xPos, y: yPos)
        label.isHidden = isHidden
        label.zPosition = zPosition
        
        return label
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
    
    func circleContainsCircle(_ circle1: SKSpriteNode, _ circle2: SKSpriteNode) -> Bool {
        let circle1In2 = eulerDistance(circle2.position, circle1.position) + circle1.width * 0.5 + circle2.width * 0.5 <= 2 * circle2.width * 0.5
        let circle2In1 = eulerDistance(circle1.position, circle2.position) + circle2.width * 0.5 + circle1.width * 0.5 <= 2 * circle1.width * 0.5
        return circle1In2 || circle2In1
    }
    
    func eulerDistance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2))
    }
    
    func fadeAndRemove(node: SKNode) {
        let fadeOutAction = SKAction.fadeOut(withDuration: 2.0)
        let remove        = SKAction.run({ node.removeFromParent }())
        let sequence      = SKAction.sequence([fadeOutAction, remove])
        node.run(sequence)
    }
    
    fileprivate func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
}

extension GameScene {
    func checkForHighscore() -> Bool {
        let highscore = UserDefaults.standard.integer(forKey: "highscore")
        if score > highscore {
            UserDefaults.standard.set(score, forKey: "highscore")
            return true
        }
        return false
    }
    
    func share(_ message: String) {
        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = self.viewController.view
            popOver.sourceRect = self.viewController.view.bounds
        }
        
        self.viewController.present(activityVC, animated: true, completion: nil)
    }
    
    func showPurchaseAlert() {
        let alertController = UIAlertController(title: "Purchase No Ads", message: "", preferredStyle: .alert)
        
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default) { (action) in
            self.attemptToBuyNoAds()
        }
        alertController.addAction(purchaseAction)
        
        let restoreAction = UIAlertAction(title: "Restore purchase", style: .default) { (action) in
            IAPHandler.shared.restorePurchase()
        }
        alertController.addAction(restoreAction)
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { (action) in }
        alertController.addAction(closeAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

extension TutorialScene {
    func movedBallFromInitialPosition() -> Bool {
        return eulerDistance(ball.position, Config.ball.initialPosition) > 15
    }
}
