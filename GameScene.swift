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

enum Directions: UInt32 {
    case N, S, E, W, NE, NW, SE, SW, none
    
    private static let _count: Directions.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = Directions(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func randomDirection() -> Directions {
        // pick and return a new value
        let rand = arc4random_uniform(_count)
        return Directions(rawValue: rand)!
    }
}

class GameScene: BaseScene {
    // Sprites
    let shareButton = SKSpriteNode(imageNamed: "share_button")
    let soundButton = SKSpriteNode(imageNamed: "sound")
    let noAds = SKSpriteNode(imageNamed: "no_ads")
    let closeBannerButton = SKSpriteNode(imageNamed: "close_banner")
    
    // Shapes
    var bannerBackground = SKShapeNode()
    
    // Labels
    var pausedLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var noAdsLabel = SKLabelNode()
    var noAdsLabel2 = SKLabelNode()
    
    // Sounds
    let loseSound = SKAudioNode(fileNamed: "lose.wav")
    
    // Constant values
    let difficultySteps: [Int] = [0, 5, 15, 30, 50, 75, 100, 150, 300]
    let hoopMovementSpeeds: [CGFloat] = [0, 0.001, 0.001, 0.001, 0.002, 0.002, 0.002, 0.003, 0.003] // speed <= 0.003
    let courtIncreaseRates: [CGFloat] = [1.02, 1.02, 1.022, 1.023, 1.025, 1.026, 1.028, 1.029, 1.03] // 1.02 <= rate <= 1.03
    
    // Game Variables
    var gameStarted = false
    var gameIsPaused = false
    var finishedGame = false
    var bannerPresent = false
    var score: Int = 0
    var basketsScoredInARow: Int = 0
    var menuElements: [SKNode] = []
    var scoredBaskets: [SKSpriteNode] = []
    
    var currentDifficultyStep = 0
    var currentHoopMovementSpeed: CGFloat = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else { return }
            if type == .purchased || type == .restored {
                strongSelf.noAds.removeFromParent()
                UserDefaults.standard.set(true, forKey: "purchasedNoAds")
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
                alertView.addAction(action)
                strongSelf.viewController.present(alertView, animated: true, completion: nil)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.nothingToRestore), name: NSNotification.Name(rawValue: "nothingToRestore"), object: nil)
        
        createLabels()
        createCourt()
        createBall()
        createSound()
        createShareButton(inMenu: true)
        
        if !UserDefaults.standard.bool(forKey: "purchasedNoAds") {
            createNoAdsButton()
        }
        
        if canPlay {
            currentCourtIncreaseRate = courtIncreaseRates[0]
            currentHoopMovementSpeed = hoopMovementSpeeds[0]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if finishedGame {
                if bannerPresent {
                    if closeBannerButton.contains(location) {
                        closeBannerButton.removeFromParent()
                        bannerBackground.removeFromParent()
                        noAdsLabel.removeFromParent()
                        noAdsLabel2.removeFromParent()
                        bannerPresent = false
                    }
                } else {
                    if shareButton.contains(location) {
                        let textToShare = "I just scored \(score) \(score == 1 ? "basket" : "baskets") on Infinite Basketball Hoops! Try to beat me, it's free! #InfiniteBasketballHoops"
                        
                        share(textToShare)
                    } else {
                        exitGame() // goes back to main menu screen
                    }
                }
            } else if worldNode.isPaused {
                if gameStarted { // unpausing started game
                    pausedLabel.isHidden = true
                    calibrate()
                    worldNode.isPaused = false
                    gameIsPaused = false
                    gameBGM.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 0.0))
                } else { // game started but player has lost
                    endGame() // goes to results screen
                }
            } else {
                if !gameStarted {
                    if soundButton.contains(location) {
                        soundIsOn = !soundIsOn
                        soundButton.texture = soundIsOn ? SKTexture(imageNamed: "sound") : SKTexture(imageNamed: "mute")
                        UserDefaults.standard.set(soundIsOn, forKey: "sound")
                        gameBGM.run(SKAction.changeVolume(to: soundIsOn ? 0.8 : 0.0, duration: 1.0))
                    } else if shareButton.contains(location) {
                        let hs = UserDefaults.standard.integer(forKey: "highscore")
                        let textToShare = "Can you beat my highscore of \(hs) \(hs == 1 ? "basket" : "baskets") on Infinite Basketball Hoops? Come try, it's free! #InfiniteBasketballHoops"
                        
                        share(textToShare)
                    } else if noAds.contains(location) && noAds.parent != nil {
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
                    } else {
                        if !canPlay {
                            showCantPlayAlert()
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
                    gameBGM.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
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
            moveHoops()
            
            if ballIsAtGoal() {
                // Check if player scored hoop
                if scoredBasket() {
                    score += 1
                    scoreLabel.text = "Score: \(score)"
                    
                    basketsScoredInARow += 1
                    
                    scoredBaskets.append(ball.copy() as! SKSpriteNode)
                    
                    if basketsScoredInARow == basketsInARowToRegainHoop {
                        basketsScoredInARow = 0
                        hoopsLeft = min(hoopsLeft + 1, maxHoops)
                    }
                    
                    if currentDifficultyStep < difficultySteps.count - 1 && score >= difficultySteps[currentDifficultyStep + 1] {
                        currentDifficultyStep += 1
                        currentCourtIncreaseRate = courtIncreaseRates[currentDifficultyStep]
                        currentHoopMovementSpeed = hoopMovementSpeeds[currentDifficultyStep]
                    }
                    
                    if soundIsOn {
                        scoreSound.run(SKAction.play())
                    }
                } else {
                    hoopsLeft -= 1
                    basketsScoredInARow = 0
                    
                    if hoopsLeft == 0 {
                        self.backgroundColor = UIColor.init(hex: 0xf92020)
                        
                        gameStarted = false
                        if soundIsOn {
                            loseSound.run(SKAction.play())
                        }
                        
                        worldNode.isPaused = true
                        return
                    }
                    
                    if soundIsOn {
                        missSound.run(SKAction.play())
                    }
                }
                
                court.size = Config.court.originalSize
                createHoops()
            }
            
            updateBallMovement()
        }
    }
    
    func moveHoops() {
        for (index, hoop) in hoops.enumerated() {
            var hoopMovement = CGVector(dx: 0, dy: 0)
            let distance = court.height * currentHoopMovementSpeed
            
            switch hoop.attributes.direction {
            case .N:
                hoopMovement.dy = distance
            case .S:
                hoopMovement.dy = -distance
            case .E:
                hoopMovement.dx = distance
            case .W:
                hoopMovement.dx = -distance
            case .NE:
                hoopMovement.dx = distance
                hoopMovement.dy = distance
            case .NW:
                hoopMovement.dx = -distance
                hoopMovement.dy = distance
            case .SE:
                hoopMovement.dx = distance
                hoopMovement.dy = -distance
            case .SW:
                hoopMovement.dx = -distance
                hoopMovement.dy = -distance
            case .none:
                break
            }
            
            let hoopWillGoOut: (inX: Bool, inY: Bool) = keepSpriteInRect(hoop.sprite, in: court.frame, with: hoopMovement)
            if hoopWillGoOut.inX { hoopMovement.dx = 0 }
            if hoopWillGoOut.inY { hoopMovement.dy = 0 }
            
            hoop.sprite.position.x += hoopMovement.dx
            hoop.sprite.position.y += hoopMovement.dy
            
            hoops[index].attributes.positionRatio = ((hoop.sprite.position.x - court.leftmostPoint) / court.width, (hoop.sprite.position.y - court.bottomPoint) / court.height)
        }
    }
    
    func showAllBaskets() {
        court.size = CGSize(width: size.width * 0.5, height: size.height * 0.5)
        court.position = CGPoint(x: size.width * 0.5, y: size.height * 0.65)
        worldNode.addChild(court)
        
        for basket in scoredBaskets {
            let basketRatio = (x: basket.position.x / size.width, y: basket.position.y / size.height)
            basket.position = CGPoint(x: court.leftmostPoint + court.width * basketRatio.x, y: court.bottomPoint + court.height * basketRatio.y)
            basket.size = CGSize(width: size.height * 0.15 * 0.5, height: size.height * 0.15 * 0.5)
            worldNode.addChild(basket)
        }
    }
    
    func endGame() {
        self.backgroundColor = Config.bgColor
        
        finishedGame = true
        
        worldNode.removeAllActions()
        worldNode.removeAllChildren()
        scoreLabel.removeFromParent()
        pausedLabel.removeFromParent()
        
        if !UserDefaults.standard.bool(forKey: "purchasedNoAds") {
            if Reachability.isConnectedToNetwork() {
                displayAd()
            } else {
                createBuyNoAdsBanner()
                bannerPresent = true
            }
        }
        
        showAllBaskets()
        
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
    
    func displayAd() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAd"), object: nil)
    }
    
    func attemptToBuyNoAds() {
        if Reachability.isConnectedToNetwork() {
            IAPHandler.shared.purchaseMyProduct(index: 0)
        } else {
            let alertView = UIAlertController(title: "Unable to purchase", message: "An internet connection is required to make the purchase.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
            alertView.addAction(action)
            self.viewController.present(alertView, animated: true, completion: nil)
        }
    }
    
    @objc func nothingToRestore() {
        let alertView = UIAlertController(title: "Unable to restore", message: "There are no previous purchases to restore.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
        alertView.addAction(action)
        self.viewController.present(alertView, animated: true, completion: nil)
    }
}
