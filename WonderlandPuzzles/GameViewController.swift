//
//  GameViewController.swift
//  WonderlandPuzzles
//
//  Created by Patricia Korn on 2/22/17.
//  Copyright © 2017 Patricia Korn. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

//    override func viewDidLoad() {
    
//        super.viewDidLoad()
    
    override func viewDidAppear(_ animated: Bool)
    {        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
             if let scene = SKScene(fileNamed: "Level1") {
//            if let scene = GameScene.level(levelNum: 1) {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill                
                
                // Present the scene
                view.presentScene(scene)
            }
//            view.showsPhysics = true
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
