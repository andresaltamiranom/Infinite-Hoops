//
//  Config.swift
//  Infinite Hoops
//
//  Created by Andres Altamirano on 5/15/18.
//  Copyright © 2018 AndresAltamirano. All rights reserved.
//

import Foundation
import SpriteKit

final class Config {
    static let defaultFont = "AmericanTypewriter-Bold"
    static let defaultFontColor = SKColor.black
    static let bgColor = UIColor.init(hex: 0x2195d1)
    static let screenSize = UIScreen.main.bounds
    
    static let menuButton: (size: CGSize, positions: [CGPoint]) =
        (CGSize(width: screenSize.width * 0.065, height: screenSize.width * 0.065),
         [CGPoint(x: screenSize.width * 0.05, y: screenSize.height * 0.9 + screenSize.width * 0.065 * 0.2),
          CGPoint(x: screenSize.width * 0.05, y: screenSize.height * 0.9 + screenSize.width * 0.065 * 0.2 - screenSize.width * 0.065 - screenSize.height * 0.05),
          CGPoint(x: screenSize.width * 0.05, y: screenSize.height * 0.9 + screenSize.width * 0.065 * 0.2 - screenSize.width * 0.065 - screenSize.height * 0.05 - screenSize.width * 0.065 - screenSize.height * 0.05)
        ])
    
    static let shareButton: (size: CGSize, position: CGPoint) =
        (CGSize(width: screenSize.width * 0.1, height: screenSize.width * 0.1),
         CGPoint(x: screenSize.width * 0.985 - screenSize.width * 0.1 * 0.5,
                 y: screenSize.height * 0.985 - screenSize.width * 0.1 * 0.5))
    
    static let court: (originalSize: CGSize, position: CGPoint) =
        (CGSize(width: screenSize.width * 0.1, height: screenSize.height * 0.1),
         CGPoint(x: screenSize.width * 0.5, y: screenSize.height * 0.5))
    
    static let ball: (size: CGSize, initialPosition: CGPoint) =
        (CGSize(width: screenSize.height * 0.15, height: screenSize.height * 0.15),
         CGPoint(x: screenSize.width * 0.5, y: screenSize.height * 0.2))
    
    private init() {}
}
