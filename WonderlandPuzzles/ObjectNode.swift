//
//  ObjectNode.swift
//  WonderlandPuzzles
//
//  Created by Patricia Korn on 2/24/17.
//  Copyright © 2017 Patricia Korn. All rights reserved.
//

import SpriteKit

class ObjectNode: SKSpriteNode
{
    var valueObject: SKSpriteNode!
    var valueObjectTextures = [SKTexture]()
    
    func didMoveToScene()
    {
        valueObjectTextures.append(SKTexture(imageNamed: "baby_bottle_transp"))
        valueObjectTextures.append(SKTexture(imageNamed: "bubbles_transp"))
        valueObjectTextures.append(SKTexture(imageNamed: "cauldron_transp"))
        valueObjectTextures.append(SKTexture(imageNamed: "ladle_transp"))
        valueObjectTextures.append(SKTexture(imageNamed: "pepper_transp"))
        valueObjectTextures.append(SKTexture(imageNamed: "pig_transp"))
        
        print("Value Object added to scene")
        
        let rand = Int(arc4random_uniform(UInt32(valueObjectTextures.count)))
        let texture = valueObjectTextures[rand] as SKTexture
        
        valueObject.texture = texture
        
        
//        physicsBody!.categoryBitMask = PhysicsCategory.ValueObject
//        physicsBody!.contactTestBitMask = PhysicsCategory.ValueObject
//        physicsBody!.collisionBitMask = PhysicsCategory.ValueObject
    }
}
