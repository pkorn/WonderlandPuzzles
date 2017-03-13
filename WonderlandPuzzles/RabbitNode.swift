//
//  RabbitNode.swift
//  WonderlandPuzzles
//
//  Created by Patricia Korn on 2/24/17.
//  Copyright © 2017 Patricia Korn. All rights reserved.
//


import SpriteKit

class RabbitNode: SKSpriteNode, EventListenerNode
{
    
    func didMoveToScene()
    {
        print("Rabbit added to scene")
        
        physicsBody!.categoryBitMask = PhysicsCategory.Rabbit
        
        
//        physicsBody!.contactTestBitMask = PhysicsCategory.ValueObject
        
//        physicsBody!.collisionBitMask = PhysicsCategory.ValueObject
    }
}
