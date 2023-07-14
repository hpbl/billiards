//
//  GameViewController.swift
//  sinuca macOS
//
//  Created by Hilton Pintor on 12/07/23.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene.newGameScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    override func viewDidAppear() {
        let skView = self.view as! SKView
        skView.window?.acceptsMouseMovedEvents = true
        skView.window?.initialFirstResponder = skView
        skView.window?.makeFirstResponder(skView.scene)
    }
}

