//
//  GameViewController.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/5/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let completedTutorial = UserDefaults.standard.bool(forKey: "completedTutorial")
        let scene = completedTutorial ? GameScene(size: view.bounds.size) : TutorialScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = false
        scene.scaleMode = .resizeFill
        scene.viewController = self
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
