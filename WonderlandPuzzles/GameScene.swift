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
    static var Blank:          UInt32 = 0b10000000 // 256
    
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
    let scoreLabel = SKLabelNode(fontNamed: "Futura")
    
    var spacesToMove: Int = 0
    var plus: SKSpriteNode!
    
    var score: Int = 0
    var lives: Int = 3
    
    let spaceSize: CGFloat = 140.0
    
    var rowDirection: CGFloat = 1.0 // will set this to 1.0 for moving right, -1.0 for moving left
    
    var moveEnded = false
    var landedOnObject = false
    var rabbitPos = 0
    var currentSpaceInRow: Int = 1
    
    let numSpacesInRow = 6
    let rowHeight:CGFloat = -280
    let bottomToTop:CGFloat = 840
    var currentRow = 1
    var spacesToRowEnd = 5
    var spacesToRowStart = 0
    var movesToMake: [CGFloat] = []
    var actionsArray: [SKAction] = []
    var endedMoveSequence = false
    var spacesOnPrevRow = 0
 

    private let walkingActionKey = "action_walking"
    private let walkRightFrames = [SKTexture(imageNamed: "whiteRabbit_100x200"),
                              SKTexture(imageNamed: "whiteRabbit2"),
                              SKTexture(imageNamed: "whiteRabbit3"),
                              SKTexture(imageNamed: "whiteRabbit_100x200")]
    
    private let walkLeftFrames = [SKTexture(imageNamed: "whiteRabbit_transp_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp2_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp3_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp_left")]
    
    var objectValues: [String: Int] = ["black_club": 0, "bubbles": 25, "shaker": 25, "pig": 50, "bottle": 75, "ladle": 75, "cauldron": 75]
    
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        path = childNode(withName: "path") as! SKTileMapNode
    }
    
    
    override func didMove(to view: SKView)
    {

//        enumerateChildNodes(withName: "//*", using: { node, _ in
//            if let EventListenerNode = node as? EventListenerNode
//            {
//                EventListenerNode.didMoveToScene()
//            }
//        })
        
        placeValueObjects()
        
        rabbitNode = childNode(withName: "//whiteRabbit") as! RabbitNode
        
        rabbitNode?.position = CGPoint(x: 0, y: -100)
        print("\n Before move, Rabbit is at \(rabbitNode.position.x) \n")
      
//        SKTAudio.sharedInstance().playBackgroundMusic("magntron__gamemusic.mp3")
        
        physicsWorld.contactDelegate = self
        
        setRandomOperands()
        
        setScoreLabel(score: score)
    }
    

    override func update(_ currentTime: TimeInterval)
    {
 //       if endedMoveSequence == true
 //       {
 //           rabbitNode.run(SKAction.moveBy(x: 0, y: 0, duration: 1.0))
 //           {
 //               self.endedMoveSequence = false
 //           }
 //       }
    }

    func placeValueObjects()
    {
        let valueObjects: [String: String] = ["bubbles": "bubbles_transp", "shaker": "pepper_transp", "pig": "pig_transp", "bottle": "baby_bottle_transp", "ladle": "ladle_transp", "cauldron": "cauldron_transp"]
        
        // initialize 6X4 2-dimensional array with 0's
        var objectPlacementArray: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 6)
        objectPlacementArray[0][0] = 1  // Don't place any objects on first space
        print(objectPlacementArray)
        
        var objectNodeArray = [objectNode]
        
 //       objectNode = ObjectNode(objectName: "pig", imageName: "pig_transp")

 //       addChild(objectNode)

        var index = 0
        for (key, value) in valueObjects
        {
            var (rndColumn, rndRow, objPos) = getRandomPosition()
            
            // if object is already in that space, choose another space
            while objectPlacementArray[rndColumn - 1][rndRow - 1] == 1
            {
                (rndColumn, rndRow, objPos) = getRandomPosition()
            }
            objectPlacementArray[rndColumn - 1][rndRow - 1] = 1
            
            objectNode = ObjectNode(objectName: key, imageName: value, objectPosition: objPos)
            addChild(objectNode)
            
            print("\n Added object \(key) with image \(value) \n at \(objPos)")
            print("\n\n The objectNode is \(objectNode?.objectName). Its position is \(objectNode?.objectPosition) \n\n")
        }
 
        // fill in blanks with blank objects
        for x in 0 ..< objectPlacementArray.count
        {
            for y in 0 ..< objectPlacementArray[x].count
            {
                if objectPlacementArray[x][y] == 0
                {
                    objectPlacementArray[x][y] = 2
                    
                    objectNode = ObjectNode(objectName: "blank", imageName: "black_club", objectPosition: getPosition(column: x, row: y))
                    objectNode?.isHidden = true
                    addChild(objectNode)
                    
                    print("\n\n The objectNode is \(objectNode?.objectName). Its position is \(objectNode?.objectPosition) \n\n")
                    
                }
            }
        }
        print(objectPlacementArray)
        print("\n\n")
        print(objectNodeArray)
    }
    

    
    func getRandomPosition() -> (Int, Int, CGPoint)
    {
        let rndColumn: Int = Int(arc4random_uniform(6)+1)    // Generates Number from 1 to 6 for columns.
        let rndRow: Int = Int(arc4random_uniform(4)+1)    // Generates Number from 1 to 4 for rows.
        
        print("\n\nColumn is \(rndColumn) and Row is \(rndRow) \n\n")
        
        let rndX = -310 + (125 * (rndColumn - 1))
        let rndY = 370 + (-220 * (rndRow - 1))
        
        let rndPos: CGPoint = CGPoint(x: rndX, y: rndY)
        
        print("\n\n rndColumn is \(rndColumn) and rndRow is \(rndRow) \n\n")
        print("\n\n rndX is \(rndX) and rndY is \(rndY) \n\n")
        
        return (rndColumn, rndRow, rndPos)
    }
    
    func getPosition(column: Int, row: Int) -> (CGPoint)
    {
        print("\n\nColumn is \(column) and Row is \(row) \n\n")
        
        let spritePosX = -310 + (125 * (column))
        let spritePosY = 370 + (-220 * (row))
        
        let spritePos: CGPoint = CGPoint(x: spritePosX, y: spritePosY)
        
        return (spritePos)
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
        
        if touched == PhysicsCategory.Rabbit | PhysicsCategory.ValueObject
        {
            print("\n The name of the value object is \(objectBody.node!.name)")
            print("The position of the value object is \(objectBody.node!.position)\n")
            print("The position of the rabbit is \(rabbitBody.node!.position)\n")
            print("\n The value object is \(objectBody.node!) \n")

            
            landedOnObject = true
            objectLandedOn = objectBody.node!
            print("endedMoveSequence is  \(endedMoveSequence)")

            
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
        print("\n\n spacesToRowStart = \(spacesToRowStart) \n\n")
        
        print("\n numSpacesInRow = \(numSpacesInRow) and currentSpaceInRow = \(currentSpaceInRow) \n")

        
        // if moving forward
        if (numSpaces > 0)
        {
            spacesToRowEnd = numSpacesInRow - currentSpaceInRow
            print("\n Going forward, spacesToRowEnd is \(spacesToRowEnd)\n")
            
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
        else if (numSpaces < 0)    // if moving backwards
        {
            // if move stays on current row
//            if (abs(numSpaces) <= currentSpaceInRow - 1)
            if (abs(numSpaces) <= currentSpaceInRow - 1)
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
        rabbitBody.categoryBitMask = PhysicsCategory.Rabbit
        rabbitBody.contactTestBitMask = PhysicsCategory.ValueObject

        
        var spacesToMoveOnThisRow:Int?
        
        if moveEnded == true
        {
            spacesToMoveOnThisRow = numSpaces
            
            if (currentRow % 2 > 0) // on an odd numbered row
            {
                rowDirection = 1
            }
            else  // on an even numbered row
            {
                rowDirection = -1
            }
            
            movesToMake.append(CGFloat(rowDirection * CGFloat(spacesToMoveOnThisRow!) * spaceSize))
        }
        else // move continues past this row
        {
            print("Moved past end of row")
            
            if (numSpaces > 0) // moving forward
            {
                spacesToMoveOnThisRow = spacesToRowEnd
            }
            else if numSpaces < 0// moving backward
            {
                spacesToMoveOnThisRow = -1 * (currentSpaceInRow - 1)
            }
            else // numspaces == 0
            {
                spacesToMoveOnThisRow = 0
            }
        }

        self.rabbitPos = self.rabbitPos + spacesToMoveOnThisRow!
        self.currentSpaceInRow = self.currentSpaceInRow + spacesToMoveOnThisRow!
        

        if self.moveEnded == false  // not on last row of move
        {
            
            if spacesToMoveOnThisRow != 0 // if we are not at the end of the row append movement on row
            {
                movesToMake.append(CGFloat(rowDirection * CGFloat(spacesToMoveOnThisRow!) * spaceSize))
            }
            
            movesToMake.append(0.0) // 0 indicates a move down or up
 
            
            if numSpaces > 0   // if positive number move
            {
                currentRow += 1
                let spacesOnNextRow = numSpaces - (self.spacesToRowEnd + 1)
                currentSpaceInRow = 1 // count spaces from right to left on even rows!
                
                if spacesOnNextRow > 0
                {
                    moveRabbit(numSpaces: spacesOnNextRow)
                }
            }
            else if numSpaces < 0 // if negative number move
            {
                currentRow -= 1
                spacesOnPrevRow = numSpaces + (abs(spacesToMoveOnThisRow!) + 1)
                
                currentSpaceInRow = 6
                
                if spacesOnPrevRow < 0
                {
                    moveRabbit(numSpaces: spacesOnPrevRow)
                }
            }
            else if numSpaces == 0
            {
                print("\n !!!!!!!! numSpaces is 0 !!!!!!!!! \n")  // this should never happen
            }
            
            

        }
        print("\n At end of moveRabbitOnRow move to numSpaces, rabbitNode.position.x is at \(self.rabbitNode.position.x) and rabbitPos is \(self.rabbitPos) and current row is \(currentRow) and currentSpaceInRow is \(self.currentSpaceInRow)\n")
    }

    func doMoveSequence()
    {
        // move x positions are now in movesToMake array. Create SKActions from them and store in actionsArray
        var aMove: SKAction
        
        actionsArray.removeAll()
        
        
        let walkRight = SKAction.animate(with: walkRightFrames, timePerFrame: 0.1)
        let walkLeft = SKAction.animate(with: walkLeftFrames, timePerFrame: 0.1)
        let walkRightNumberTimes = SKAction.repeat(walkRight, count: movesToMake.count)
        let walkLeftNumberTimes = SKAction.repeat(walkLeft, count: movesToMake.count)
        var walkNumberTimes = walkRightNumberTimes
        let playStepSound = SKAction.playSoundFileNamed("running3.mp3", waitForCompletion: false)
        let repeatStepSound = SKAction.repeat(playStepSound, count: movesToMake.count)
        // after accumulating all the path sections for the move, run the path
 

        
        for move in movesToMake
        {
        if abs(move) > 0.0  // moving on a row
        {
            aMove = SKAction.moveBy(x: move, y: 0, duration: 1.0)
            if move > 0
            {
               walkNumberTimes = walkRightNumberTimes
            }
            else
            {
                walkNumberTimes = walkLeftNumberTimes
            }
            
            aMove = SKAction.group([aMove, walkNumberTimes, repeatStepSound])
            
            
            print("Moving \(move) spaces on row")
        }
        else // move down or up if move == 0.0
        {
 
            aMove = SKAction.moveBy(x: 0, y: rowHeight, duration: 1.0)
            print("\n Moving down by \(rowHeight) pixels \n")
            
            if spacesToMove < 0  // if moving backward, replace aMove with this move to - rowHeight
            {
                aMove = SKAction.moveBy(x: 0, y: -rowHeight, duration: 1.0)
                print("%%%%%% \n Moving up by \(-rowHeight) pixels %%%%%% \n")
            }

            if currentRow > 4 &&  spacesToMove > 0 // on bottom row with positive move, go up to top
            {
                aMove = SKAction.moveBy(x: 0, y: -3 * rowHeight, duration: 1.0)
                currentRow = 1  // check whether this works with large move that goes up to top and then down to other rows
                print("Moving down by \(rowHeight) pixels")
            }
            else if currentRow < 1 && spacesToMove < 0  // on top row with negative move, go down to bottom
            {
                aMove = SKAction.moveBy(x: 0, y: 3 * rowHeight, duration: 1.0)
                currentRow = 4  // check whether this works with large move that goes up to top and then down to other rows
                print("Moving up by \(rowHeight) pixels")
            }
        }
        
        actionsArray.append(aMove)

        print("\n Appended \(aMove) to actionsArray")
        }
        
        print("actionsArray is \(actionsArray)")
        
        let moveSequence = SKAction.sequence(actionsArray)
        print("moveSequence is \(moveSequence)")
        
        print("\n @@@@@@@ movesToMake is \(movesToMake) @@@@@@@@\n")
        
        rabbitNode.run(moveSequence, completion:{
            print("\n ran sequence\n")
            print("\n Object landed on last was \(self.objectLandedOn) \n")
            
            if self.objectLandedOn.name != "blank"
            && self.objectLandedOn.isHidden == false
            {
                self.collectObject(object: self.objectLandedOn)
            }
   
        })

    }
    
    func collectObject(object: SKNode)
    {
        if let emitter = SKEmitterNode(fileNamed: "HeartsParticles.sks")
        {
            emitter.particlePosition = object.position
            
            addChild(emitter)
            run(SKAction.playSoundFileNamed("clipFromTaira-komori_fairies02.wav", waitForCompletion: false))
            object.isHidden = true
            
            var collectedObject = object.name
            
            print("\n\n The object collected was \(collectedObject)\n\n")
            
            let objectValue = objectValues[collectedObject!]
            
            print("\n\n The value of object \(collectedObject) is \(objectValue) \n\n")
            
            score += objectValue!
            
            scoreLabel.text = "Score: \(score)"
        }
        
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
                movesToMake.removeAll()
                
                self.endedMoveSequence = false
                moveRabbit(numSpaces: spacesToMove)
                doMoveSequence()
            }

            else if node.name == "secondNumber"
            {
                
                let secondValue = Int(secondNum.text!)
                spacesToMove = secondValue!
                movesToMake.removeAll()

                self.endedMoveSequence = false
                moveRabbit(numSpaces: spacesToMove)
                doMoveSequence()
            }
            
            else if node.name == "thirdNumber"
            {
                let thirdValue = Int(thirdNum.text!)
                spacesToMove = thirdValue!
                movesToMake.removeAll()
                
                self.endedMoveSequence = false
                moveRabbit(numSpaces: spacesToMove)
                doMoveSequence()
            }
        }
    }
    
    
    func getRandomNumber() -> Int
    {
        var rndOp: Int =  Int(arc4random_uniform(3)+1)    // Generates Number from 1 to 3. Change to (9)+1 in final version!
        
        return rndOp
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
        

//        firstNum.text = String(getRandomNumber())
        firstNum.text = "3"
        firstNum.name = "firstNumber"
        firstNum.fontSize = 65
        firstNum.fontColor = .black
        firstNum.horizontalAlignmentMode = .left
        firstNum.position = CGPoint(x: -318, y: -636)
        firstNum.zPosition = 8
        
        addChild(firstNum)
        
        
 //       secondNum.text = String(-1 * (getRandomNumber()))
        secondNum.text = "2"
        secondNum.name = "secondNumber"
        secondNum.fontSize = 65
        secondNum.fontColor = .black
        secondNum.horizontalAlignmentMode = .left
        secondNum.position = CGPoint(x: -237, y: -636)
        secondNum.zPosition = 8


//        thirdNum.text = String(-1 * (getRandomNumber()))
        thirdNum.text = "-3"
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
            secondNum.text = String(-1 * (getRandomNumber()))
        }
        // if third operand button same as 1st or 2nd button, get another digit
        while thirdNum.text == firstNum.text || thirdNum.text == secondNum.text
        {
            thirdNum.text = String(-1 * (getRandomNumber()))
        }
        

        addChild(secondNum)
        addChild(thirdNum)
    }
    

    
    func setScoreLabel(score: Int)
    {
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 65
//        scoreLabel.fontColor = UIColor(red: 0.0, green: 40.0, blue: 217.0, alpha: 1.0)
        scoreLabel.fontColor = SKColor(red: 0.1, green: 0.5, blue: 1.0, alpha: 1.0)
//        scoreLabel.fontColor = .blue
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: -350, y: 583)
        scoreLabel.zPosition = 8
        addChild(scoreLabel)
    }
    

} // end of class GameScene

