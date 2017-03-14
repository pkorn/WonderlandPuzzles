//
//  GameScene.swift
//  WonderlandPuzzles
//
//  Created by Patricia Korn on 2/22/17.
//  Copyright © 2017 Patricia Korn. All rights reserved.
//

import SpriteKit

protocol EventListenerNode
{
    func didMoveToScene()
}

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
    
//
}
class GameScene: SKScene, SKPhysicsContactDelegate
{
    var path: SKTileMapNode!
    var rabbitNode: RabbitNode!
    var objectNode: ObjectNode!
    var fgNode: SKNode!
    var hearts: SKSpriteNode!
    var objectLandedOn: SKNode!
  
    
    let firstNum = SKLabelNode(fontNamed: "Futura")
    let secondNum = SKLabelNode(fontNamed: "Futura")
    let thirdNum = SKLabelNode(fontNamed: "Futura")
    var spacesToMove: Int = 0
    var plus: SKSpriteNode!

    
    var forwardSpace: CGFloat = 140.0
    
    var moveEnded = false
    var landedOnObject = false
    var contactPos: CGPoint?
    var rabbitPos = 0
    var currentSpaceInRow: Int = 1
    
    let numSpacesInRow = 6
    let rowHeight:CGFloat = -280
    let bottomToTop:CGFloat = 840
    var currentRow = 1
    var spacesToRowEnd = 5
    var spacesToRowStart = 0
    var movePath = CGMutablePath()
    

    private let walkingActionKey = "action_walking"
    private let walkFrames = [SKTexture(imageNamed: "whiteRabbit_100x200"),
                              SKTexture(imageNamed: "whiteRabbit2"),
                              SKTexture(imageNamed: "whiteRabbit3"),
                              SKTexture(imageNamed: "whiteRabbit_100x200")]
    
    private let walkLeftFrames = [SKTexture(imageNamed: "whiteRabbit_transp_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp2_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp3_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp_left")]
    

    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        path = childNode(withName: "path") as! SKTileMapNode
    
    }
    
    
    override func didMove(to view: SKView)
    {
        enumerateChildNodes(withName: "//*", using: { node, _ in
            if let EventListenerNode = node as? EventListenerNode
            {
                EventListenerNode.didMoveToScene()
            }
        })
        
        rabbitNode = childNode(withName: "//whiteRabbit") as! RabbitNode
        movePath.move(to: CGPoint(x: 50, y: 0))
        
        let shape = SKShapeNode()
        shape.path = movePath
    
        shape.strokeColor = .red
        shape.lineWidth = 2
        addChild(shape)
        
 //       rabbitNode?.position = CGPoint(x: 50, y: 0)
        
        print("\n Before move, Rabbit is at \(rabbitNode.position.x) \n")
        
//        SKTAudio.sharedInstance().playBackgroundMusic("magntron__gamemusic.mp3")
        
        physicsWorld.contactDelegate = self
        
        setRandomOperands()
    }

    
    func didBegin(_ contact: SKPhysicsContact)
    {
        print("Contact detected")
        var rabbitBody: SKPhysicsBody
        var objectBody: SKPhysicsBody
        
        let touched = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            rabbitBody = contact.bodyA
            objectBody = contact.bodyB
        }
        else
        {
            rabbitBody = contact.bodyB
            objectBody = contact.bodyA
        }
        
        contactPos = contact.contactPoint

//        print("Before check, currentSpaceInRow is \(currentSpaceInRow) and Rabbit's x position is at \(rabbitNode.position.x) \n and rabbitPos is \(rabbitPos) and spacesToMove is \(spacesToMove) and moveEnded is \(moveEnded)")
        
        if touched == PhysicsCategory.Rabbit | PhysicsCategory.ValueObject // && rabbitPos == spacesToMove  && (Int(rabbitNode.position.x) >  (140 * (currentSpaceInRow - 2)))  && moveEnded == true
        {
            print("\n The name of the value object is \(objectBody.node!.name)")
            print("The position of the value object is \(objectBody.node!.position)\n")
            print("The position of the rabbit is \(rabbitBody.node!.position)\n")

            
            landedOnObject = true
            objectLandedOn = objectBody.node!
            print("Landed on an object")
        }
        else
        {
            print("Passed through an object")
        }
    }
    
    
    func moveRabbit(numSpaces: Int)
    {
        moveEnded = false
        rabbitPos = 0 // keep track of whether rabbit has moved all the spaces yet
        spacesToRowStart = currentSpaceInRow - 1
        print("spacesToRowStart = \(spacesToRowStart)")
        
        print("numSpacesInRow = \(numSpacesInRow) and currentSpaceInRow = \(currentSpaceInRow)")
        
        spacesToRowEnd = numSpacesInRow - currentSpaceInRow
        print("\n spacesToRowEnd is \(spacesToRowEnd)\n")
        
        // if moving forward
        if (numSpaces > 0)
        {
            // if move stays on current row
            if (numSpaces <= spacesToRowEnd)
            {
                moveEnded  = true  // move will end on this row
            }
            else
            {
                moveEnded = false  // move will continue past this row
            }
           
            moveRabbitOnRow(numSpaces: numSpaces)
        }

        
    }
    
 
    func moveRabbitOnRow(numSpaces: Int)
    {
        var rabbitBody: SKPhysicsBody
        rabbitBody = self.rabbitNode.physicsBody!
        rabbitBody.contactTestBitMask = PhysicsCategory.ValueObject
        
        var spacesToMoveOnThisRow:Int?
        
        if moveEnded == true
        {
            spacesToMoveOnThisRow = numSpaces
        }
        else // move continues past this row
        {
            print("Moved past end of row")
            
            if (numSpaces >= 0) // moving forward
            {
                spacesToMoveOnThisRow = spacesToRowEnd
            }
            else // moving backward
            {
                spacesToMoveOnThisRow = -1 * spacesToRowStart
            }
        }

        self.rabbitPos = self.rabbitPos + spacesToMoveOnThisRow!
        self.currentSpaceInRow = self.currentSpaceInRow + spacesToMoveOnThisRow!
        
        // odd numbered rows - move right (add to x)
        if (currentRow % 2 > 0)
        {
            print("\n ^^^^^^^^^ Before addLine rabbitPos is \(rabbitPos) and currentSpaceInRow is \(currentSpaceInRow)^^^^^^^^^ \n")
            movePath.addLine(to: CGPoint(x: CGFloat((currentSpaceInRow - 1) * 140), y: 0))
            
            if self.moveEnded == false  // not on last row of move
            {
                
 //               self.movePath.addLine(to: CGPoint(x: CGFloat(currentSpaceInRow * 140), y: self.rowHeight)) // add move down line to path
                self.moveRabbit(numSpaces: numSpaces - (self.spacesToRowEnd + 1))
                currentRow += 1
            }
        }
        else // even numbered rows - move left (syv
        {
//            movePath.addLine(to: CGPoint(x: CGFloat(currentSpaceInRow * -140), y: 0))

            if self.moveEnded == false  // not on last row of move
            {
 //               self.movePath.addLine(to: CGPoint(x: CGFloat(currentSpaceInRow * -140), y: self.rowHeight)) // add move down line to path
                self.moveRabbit(numSpaces: numSpaces - (self.spacesToRowEnd + 1))
                currentRow += 1
            }
            
        }

        // after accumulating all the path sections for the move, run the path
        let walk = SKAction.animate(with: walkFrames, timePerFrame: 0.1)
                let walkNumberTimes = SKAction.repeat(walk, count: spacesToMove)
                let playStepSound = SKAction.playSoundFileNamed("running3.mp3", waitForCompletion: false)
                let repeatStepSound = SKAction.repeat(playStepSound, count: spacesToMove)
                
                let followLine = SKAction.follow(movePath, asOffset: true, orientToPath: false, duration: TimeInterval(spacesToMove))
                let group = SKAction.group([followLine, repeatStepSound])  //walkNumberTimes,
                
                rabbitNode.run(group, completion: {
                    self.collectObject(object: self.objectLandedOn!)
                    self.objectLandedOn?.run(SKAction.scale(to: 0.8, duration: 0.1))
                    self.objectLandedOn?.run(SKAction.removeFromParent())
                    self.movePath.closeSubpath()
                })
        
        print("\n At end of moveRabbitOnRow move to numSpaces, rabbitNode.position.x is at \(self.rabbitNode.position.x) and rabbitPos is \(self.rabbitPos) and currentSpaceInRow is \(self.currentSpaceInRow)\n")
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            if node.name == "plus"
            {
                print("Touched the plus sign")
            }
            else if node.name == "minus"
            {
                print("Touched the minus sign")
            }
            else if node.name == "times"
            {
                print("Touched the times sign")
            }
            else if node.name == "equals"
            {
                print("Touched the equals sign")
            }
            else if node.name == "firstNumber"
            {
                
                let firstValue = Int(firstNum.text!)
                spacesToMove = firstValue!
                moveRabbit(numSpaces: spacesToMove)
            }

            else if node.name == "secondNumber"
            {
                
                let secondValue = Int(secondNum.text!)
                spacesToMove = secondValue!
                moveRabbit(numSpaces: spacesToMove)
            }
            
            else if node.name == "thirdNumber"
            {
                
                let thirdValue = Int(thirdNum.text!)
                spacesToMove = thirdValue!
                moveRabbit(numSpaces: spacesToMove)
            }
        }
    }
        
    
    func collectObject(object: SKNode)
    {  
        if let emitter = SKEmitterNode(fileNamed: "HeartsParticles.sks")
        {
            emitter.particlePosition = object.position
            
            addChild(emitter)
            run(SKAction.playSoundFileNamed("clipFromTaira-komori_fairies02.wav", waitForCompletion: false))
        }

    }
    
    func getRandomNumber() -> String
    {
        let rndOp =  arc4random_uniform(3)+1     // Generates Number from 1 to 3. Change to (9)+1 in final version!
        
        return String(rndOp)
    }
    
    func getRandomY() -> Int
    {
        let rndY = arc4random_uniform(4)+1        //Generates Number from 1 to 4 (number of rows).
        return Int(rndY)
    }
    
    func getRandomX() -> Int
    {
        let rndX = arc4random_uniform(6)+1        //Generates Number from 1 to 6(number of columns).
            return Int(rndX)
    }

    
    func setRandomOperands()
    {
        

        firstNum.text = getRandomNumber()
        firstNum.name = "firstNumber"
        firstNum.fontSize = 65
        firstNum.fontColor = .black
        firstNum.horizontalAlignmentMode = .left
        firstNum.position = CGPoint(x: -318, y: -636)
        firstNum.zPosition = 8
        
        addChild(firstNum)
        
        
        secondNum.text = getRandomNumber()
        secondNum.name = "secondNumber"
        secondNum.fontSize = 65
        secondNum.fontColor = .black
        secondNum.horizontalAlignmentMode = .left
        secondNum.position = CGPoint(x: -237, y: -636)
        secondNum.zPosition = 8


        thirdNum.text = getRandomNumber()
        thirdNum.name = "thirdNumber"
        thirdNum.fontSize = 65
        thirdNum.fontColor = .black
        thirdNum.horizontalAlignmentMode = .left
        thirdNum.position = CGPoint(x: -165, y: -636)
        thirdNum.zPosition = 8

        //  Prevent duplicate digits
        // if second operand button same as 1st button, get another digit
        while firstNum.text  == secondNum.text
        {
            secondNum.text = getRandomNumber()
        }
        // if third operand button same as 1st or 2nd button, get another digit
        while thirdNum.text == firstNum.text || thirdNum.text == secondNum.text
        {
            thirdNum.text = getRandomNumber()
        }
        

        addChild(secondNum)
        addChild(thirdNum)
    }

} // end of class GameScene

