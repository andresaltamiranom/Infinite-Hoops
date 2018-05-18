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
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {

    var myAd: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAd()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showAd), name: NSNotification.Name(rawValue: "showAd"), object: nil)
        
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
    
    @objc func loadAd() {
//        myAd = GADInterstitial(adUnitID: "ca-app-pub-8282617988296147/2409455043")
         myAd = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        myAd.delegate = self
        myAd.load(GADRequest())
    }
    
    @objc func showAd() {
        if self.myAd.isReady {
            myAd.present(fromRootViewController: self)
        } else {
            loadAd()
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        loadAd()
    }
}
