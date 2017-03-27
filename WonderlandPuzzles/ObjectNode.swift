//
//  ObjectNode.swift
//  WonderlandPuzzles
//
//  Created by Patricia Korn on 2/24/17.
//  Copyright © 2017 Patricia Korn. All rights reserved.
//

import SpriteKit

class ObjectNode: SKSpriteNode, SKPhysicsContactDelegate
{
    struct PhysicsCategory
    {
        static let None:           UInt32 = 0          // 0
        static var Rabbit:         UInt32 = 0b1        // 1
        static let ValueObject:    UInt32 = 0b10       // 2
        static var Bubbles1:       UInt32 = 0b100      // 4
        static var Pig1:           UInt32 = 0b1000     // 8
        static var Ladle1:         UInt32 = 0b10000    // 16
        static var Bottle1:        UInt32 = 0b100000   // 32
        static var Shaker1:        UInt32 = 0b1000000  // 64
        static var Cauldron1:      UInt32 = 0b1000000  // 128
        static var Blank:          UInt32 = 0b10000000 // 256
    }

    
    let objectName: String = ""
    let imageName: String = ""
    let objectPosition: CGPoint = CGPoint.zero
    
    init(objectName: String, imageName: String, objectPosition: CGPoint)
    {
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = objectName
        self.setScale(2.2)
        self.position = objectPosition
        self.zPosition = 6
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody?.isDynamic = false
        
        self.physicsBody!.categoryBitMask = PhysicsCategory.ValueObject
        self.physicsBody!.contactTestBitMask = PhysicsCategory.ValueObject
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Rabbit
        self.physicsBody!.collisionBitMask = 0
    }

    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func didMoveToScene()
    {
        print("Object added to scene")
        
        physicsBody!.categoryBitMask = PhysicsCategory.ValueObject
        physicsBody!.contactTestBitMask = PhysicsCategory.ValueObject
        
        //        physicsBody!.collisionBitMask = PhysicsCategory.ValueObject
        
        //        let rabbitBodySize = CGSize(width: 100, height: 100)
        //        physicsBody = SKPhysicsBody(rectangleOf: rabbitBodySize)
        physicsBody!.isDynamic = false
        
    }
}



