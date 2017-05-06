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
    static let None:           UInt32 = 0           // 0
    static var Rabbit:         UInt32 = 0b1         // 1
    static let ValueObject:    UInt32 = 0b10        // 2
    static var Bubbles1:       UInt32 = 0b100       // 4
    static var Pig1:           UInt32 = 0b1000      // 8
    static var Ladle1:         UInt32 = 0b10000     // 16
    static var Bottle1:        UInt32 = 0b100000    // 32
    static var Shaker1:        UInt32 = 0b1000000   // 64
    static var Cauldron1:      UInt32 = 0b1000000   // 128
    static var Blank:          UInt32 = 0b10000000  // 256
    static var Invitation:     UInt32 = 0b100000000 // 512
//
}
class GameScene: SKScene, SKPhysicsContactDelegate
{
//    var background = SKSpriteNode(imageNamed: "background_PepperSoup")
    var path: SKTileMapNode!
    var rabbitNode: RabbitNode!
    var objectNode: ObjectNode!
    var invitationNode: ObjectNode!
    var level = "Pepper"
    
    var fgNode: SKNode!
    var hearts: SKSpriteNode!
    var objectLandedOn: SKNode!
  
    
    let firstNum = SKLabelNode(fontNamed: "Futura")
    let secondNum = SKLabelNode(fontNamed: "Futura")
    let thirdNum = SKLabelNode(fontNamed: "Futura")
    let scoreLabel = SKLabelNode(fontNamed: "Futura")
    let bonusLabel = SKLabelNode(fontNamed: "Futura")
    let equationDisplay = SKLabelNode(fontNamed: "Futura")
    var moveLabel = SKLabelNode()
    var clearLabel = SKLabelNode()
    var deleteLabel = SKLabelNode()
    var plusSprite = SKSpriteNode()
    var minusSprite = SKSpriteNode()
    var timesSprite = SKSpriteNode()
    var equalsSprite = SKSpriteNode()
    var extraOperation = ""
    
    var digitSelected: Int = 0
    var spacesToMoveOnThisRow: Int = 0
    var plus: SKSpriteNode!
    
    var score: Int = 0
    var lives: Int = 3

    
    let spaceSize: CGFloat = 227.0  // was 140.0
    
    var rowDirection: CGFloat = 1.0 // will set this to 1.0 for moving right, -1.0 for moving left
    
    var moveEnded = false
    var landedOnObject = false
    var rabbitPos = 0
    var currentSpaceInRow: Int = 1
    
    let numSpacesInRow = 10  // was 6
    let rowHeight:CGFloat = -270  // was -280
    let bottomToTop:CGFloat = 840
    var currentRow = 1
    var spacesToRowEnd = 9
    var spacesToRowStart = 0
    var movesToMake: [CGFloat] = []
    var actionsArray: [SKAction] = []
    var endedMoveSequence = false
    var spacesOnPrevRow = 0
    var operatorCount = 0
    var digitEntered = false
    var answer: Int = 0
    var numberExpected = true   // expect user to enter number or operator
    var usedTimes = false
    var usedAllOperations = false
    var numberOfObjectsCollected = 0
    
    private let walkingActionKey = "action_walking"
    private let walkRightFrames = [SKTexture(imageNamed: "whiteRabbit_100x200"),
                              SKTexture(imageNamed: "whiteRabbit2"),
                              SKTexture(imageNamed: "whiteRabbit3"),
                              SKTexture(imageNamed: "whiteRabbit_100x200")]
    
    private let walkLeftFrames = [SKTexture(imageNamed: "whiteRabbit_transp_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp2_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp3_left"),
                              SKTexture(imageNamed: "whiteRabbit_transp_left")]
    
    var objectValues: [String: Int] = ["black_club": 0, "bubbles": 25, "shaker": 25, "pig": 50, "bottle": 75, "ladle": 75, "cauldron": 75, "invitation": 0]
    
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        path = childNode(withName: "path") as! SKTileMapNode
    }
    
    
    override func didMove(to view: SKView)
    {
        placeValueObjects()
        
        rabbitNode = childNode(withName: "//whiteRabbit") as! RabbitNode
        
        rabbitNode?.position = CGPoint(x: 0, y: -100)
//        print("\n Before move, Rabbit is at \(rabbitNode.position.x) \n")
      
//        SKTAudio.sharedInstance().playBackgroundMusic("magntron__gamemusic.mp3")
        
        physicsWorld.contactDelegate = self
        
        setRandomOperands()
        operatorCount = 0
        setScoreLabel(score: score)
        setBonusLabel(bonus: "")
        setEquationDisplay()
        moveLabel = childNode(withName: "Move") as! SKLabelNode
        moveLabel.name = "move"
        moveLabel.isHidden = true
        clearLabel = childNode(withName: "Clear") as! SKLabelNode
        clearLabel.name = "clear"
        clearLabel.isHidden = true
        deleteLabel = childNode(withName: "Delete") as! SKLabelNode
        deleteLabel.name = "delete"
        deleteLabel.isHidden = true
        plusSprite = childNode(withName: "plus") as! SKSpriteNode
        plusSprite.name = "plus"
        minusSprite = childNode(withName: "minus") as! SKSpriteNode
        minusSprite.name = "minus"
        timesSprite = childNode(withName: "times") as! SKSpriteNode
        timesSprite.name = "times"
        equalsSprite = childNode(withName: "equals") as! SKSpriteNode
        equalsSprite.name = "equals"
    }
    

    func placeValueObjects()
    {
        let valueObjects: [String: String] = ["bubbles": "bubbles_transp", "shaker": "pepper_transp", "pig": "pig_transp", "bottle": "baby_bottle_transp", "ladle": "ladle_transp", "cauldron": "cauldron_transp", "invitation": "invitation_transp"]
        
        // initialize 10X4 2-dimensional array with 0's
        var objectPlacementArray: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 10)
        objectPlacementArray[0][0] = 1  // Don't place any objects on first space
//        print(objectPlacementArray)
        
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
            if objectNode.name == "invitation"
            {
                objectNode.isHidden = true
                invitationNode = objectNode
            }
            addChild(objectNode)
            
//            print("\n Added object \(key) with image \(value) \n at \(objPos)")
//            print("\n\n The objectNode is \(objectNode?.objectName). Its position is \(objectNode?.objectPosition) \n\n")
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
                    
//                    print("\n\n The objectNode is \(objectNode?.objectName). Its position is \(objectNode?.objectPosition) \n\n")
                    
                }
            }
        }
    }
    
    
    func getRandomPosition() -> (Int, Int, CGPoint)
    {
        let rndColumn: Int = Int(arc4random_uniform(10)+1)    // Generates Number from 1 to 10 for columns.
        let rndRow: Int = Int(arc4random_uniform(4)+1)    // Generates Number from 1 to 4 for rows.
        
//        print("\n\nColumn is \(rndColumn) and Row is \(rndRow) \n\n")
        
//        let rndX = -310 + (125 * (rndColumn - 1))
//        let rndY = 370 + (-220 * (rndRow - 1))
        
        let rndX = -938 + (205 * (rndColumn - 1))
        let rndY = 365 + (-218 * (rndRow - 1))
        
        let rndPos: CGPoint = CGPoint(x: rndX, y: rndY)
        
//        print("\n\n rndColumn is \(rndColumn) and rndRow is \(rndRow) \n\n")
//        print("\n\n rndX is \(rndX) and rndY is \(rndY) \n\n")
        
        return (rndColumn, rndRow, rndPos)
    }
    
    func getPosition(column: Int, row: Int) -> (CGPoint)
    {
//        print("\n\nColumn is \(column) and Row is \(row) \n\n")
        
        let spritePosX = -938 + (205 * (column))
        let spritePosY = 365 + (-218 * (row))
        
        let spritePos: CGPoint = CGPoint(x: spritePosX, y: spritePosY)
        
        return (spritePos)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact)
    {
//        print("Contact detected")
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
            /*
            print("\n The name of the value object is \(objectBody.node!.name)")
            print("The position of the value object is \(objectBody.node!.position)\n")
            print("The position of the rabbit is \(rabbitBody.node!.position)\n")
            print("\n The value object is \(objectBody.node!) \n")
*/
            
            landedOnObject = true
            objectLandedOn = objectBody.node!
//            print("endedMoveSequence is  \(endedMoveSequence)")

            
//            print("Landed on an object")
        }
        else
        {
//            print("Passed through an object")
        }
    }
    
    
    func moveRabbit(numSpaces: Int)
    {
        moveEnded = false
        rabbitPos = 0 // keep track of whether rabbit has moved all the spaces yet
        spacesToRowStart = currentSpaceInRow - 1
        
        // if moving forward
        if (numSpaces > 0)
        {
            spacesToRowEnd = numSpacesInRow - currentSpaceInRow
            
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

        
//        var spacesToMoveOnThisRow:Int?
        
        // NEED TO CHECK currentRow or rowDirection WHEN MOVING MORE THAN 1 ROW DOWN OR UP
        
        if (currentRow % 2 > 0) // on an odd numbered row
        {
            rowDirection = 1
        }
        else  // on an even numbered row
        {
            rowDirection = -1
        }
        
        if moveEnded == true
        {
            spacesToMoveOnThisRow = numSpaces
            
//            if (currentRow % 2 > 0) // on an odd numbered row
//            {
//                rowDirection = 1
//            }
//            else  // on an even numbered row
//            {
//                rowDirection = -1
//            }
            
            movesToMake.append(CGFloat(rowDirection * CGFloat(spacesToMoveOnThisRow) * spaceSize))
        }
        else // move continues past this row
        {
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

        self.rabbitPos = self.rabbitPos + spacesToMoveOnThisRow
        self.currentSpaceInRow = self.currentSpaceInRow + spacesToMoveOnThisRow
        

        if self.moveEnded == false  // not on last row of move
        {
            
            if spacesToMoveOnThisRow != 0 // if we are not at the end of the row append movement on row
            {
                movesToMake.append(CGFloat(rowDirection * CGFloat(spacesToMoveOnThisRow) * spaceSize))
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
                spacesOnPrevRow = numSpaces + (abs(spacesToMoveOnThisRow) + 1)
                
 //               currentSpaceInRow = 6
                currentSpaceInRow = 10
                
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
    }

    func doMoveSequence()
    {
        print("\n At start of doMoveSequence, operationStack contains \(operationStack)\n")
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
 
        print("\n movesToMake is \(movesToMake)")
        
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
            
            
            print("\n Moving \(move) spaces on row\n")
        }
        else // move down or up if move == 0.0
        {
            print("\n Moving up or down a row \n")
            aMove = SKAction.moveBy(x: 0, y: rowHeight, duration: 1.0)
            print("\n spacesToMoveOnThisRow is \(spacesToMoveOnThisRow) \n")
            if spacesToMoveOnThisRow < 0  // if moving backward, replace aMove with this move to - rowHeight
            {
                aMove = SKAction.moveBy(x: 0, y: -rowHeight, duration: 1.0)
                print("%%%%%% \n Moving back by \(-rowHeight) pixels %%%%%% \n")
            }

            if currentRow > 4 &&  spacesToMoveOnThisRow > 0 // on bottom row with positive move, go up to top
            {
                aMove = SKAction.moveBy(x: 0, y: -3 * rowHeight, duration: 1.0)
                currentRow = 1  // check whether this works with large move that goes up to top and then down to other rows
                print("/n Moving up by \(rowHeight) pixels\n")
            }
            else if currentRow < 1 && spacesToMoveOnThisRow <= 0  // on top row with negative move, go down to bottom
            {
                aMove = SKAction.moveBy(x: 0, y: 3 * rowHeight, duration: 1.0)
                currentRow = 4  // check whether this works with large move that goes down to bottom and then up to other rows
                print("\nMoving down to bottom by \(rowHeight) pixels\n")
            }
            print("\n currentSpaceInRow is \(currentSpaceInRow)\n")
        }
        
        actionsArray.append(aMove)

//        print("\n Appended \(aMove) to actionsArray")
        }

        print("actionsArray is \(actionsArray)")
        
        let moveSequence = SKAction.sequence(actionsArray)
        print("moveSequence is \(moveSequence)")
        
        print("\n @@@@@@@ movesToMake is \(movesToMake) @@@@@@@@\n")
        print("\n Before running moveSequence, operationStack contains \(operationStack)\n")
        
        usedTimes = false
        usedAllOperations = false
        bonusLabel.text = ""
        
        for op in operationStack
        {
            if op == "x"
            {
                usedTimes = true
            }
        }
        
        if operationStack.count > 1
        {
            usedAllOperations = true
        }
        
        rabbitNode.run(moveSequence, completion:{
              print("\n In run moveSequence, operationStack contains \(operationStack)\n")
  //          print("\n ran sequence\n")
//            print("\n Object landed on last was \(self.objectLandedOn) \n")
            
            if self.objectLandedOn.name != "blank"
            && self.objectLandedOn.isHidden == false
            {
                self.collectObject(object: self.objectLandedOn)
            }
           
            // move has been run, get new numbers for a new equation
            self.getNewNumbers()
        })
    }
    
    
    func collectObject(object: SKNode)
    {
        print("\n At the start of collectObject, operationStack contains \(operationStack)\n")
        if let emitter = SKEmitterNode(fileNamed: "HeartsParticles.sks")
        {
            emitter.particlePosition = object.position
            
            addChild(emitter)
            run(SKAction.playSoundFileNamed("clipFromTaira-komori_fairies02.wav", waitForCompletion: false))
            object.isHidden = true
            numberOfObjectsCollected += 1
            
            let collectedObject = object.name
            
            print("\n\n The object collected was \(String(describing: collectedObject))\n\n")
            
            if collectedObject == "invitation"
            {
                levelUp()
            }
            
            var objectValue = objectValues[collectedObject!]
            
            
            // if times was used, display bonus message
            print("\n In collectObject, usedTimes is \(usedTimes)\n")
            var bonusStr = ""
            var bonusValue = objectValue
            
                if usedTimes == true
                {
                    bonusStr = "Multiplication Bonus! Double Points!"
                    bonusValue = objectValue! * 2
                }
            
                if usedAllOperations == true
                {
                    bonusStr = "Used All the Numbers! Triple Points!"
                    bonusValue = objectValue! * 3
                }
            
                if usedAllOperations == true && usedTimes == true
                {
                    bonusStr = "Used x and All the Numbers! 6x Points!"
                    bonusValue = objectValue! * 6
                }
            
            self.bonusLabel.text = bonusStr
            print("\n Object Value was \(String(describing: objectValues[collectedObject!])) and Bonus Value is \(String(describing: bonusValue)) \n")


            
//            print("\n\n The value of object \(String(describing: collectedObject)) is \(String(describing: objectValue)) \n\n")
            
            score += bonusValue!
            
            scoreLabel.text = "Score: \(score)"
            
            print("\nNumber of objects collected is \(numberOfObjectsCollected) and objectValues.count is \(objectValues.count)\n")
            if numberOfObjectsCollected >= objectValues.count - 2 // the 'blank' club and the invitation must be subtracted from the count
            {
                invitationNode.isHidden = false
            }
        }
    }
    
    
    func getNewNumbers()
    {
        // get new numbers to make next equation
        firstNum.text = String(getRandomNumber())
        firstNum.isHidden = false
        secondNum.text = String(getRandomNumber())
        secondNum.isHidden = false
        thirdNum.text = String(getRandomNumber())
        thirdNum.isHidden = false
        
        operatorCount = 0
        
        plusSprite.isHidden = false
        minusSprite.isHidden = false
        timesSprite.isHidden = false
        equalsSprite.isHidden = false
        
        clearLabel.isHidden = true
        deleteLabel.isHidden = true
        moveLabel.isHidden = true
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if !numberExpected
            {
                if node.name == "plus"
                {
 //                   print("Touched the plus sign")
                    node.isHidden = true
                    equationDisplay.text! = equationDisplay.text! +  " +"
                   
                    operationPressed(operation: "+")
                    numberExpected = true
                }
                else if node.name == "minus"
                {
 //                   print("Touched the minus sign")
                    node.isHidden = true
                    equationDisplay.text! = equationDisplay.text! +  " -"
                    operatorCount += 1
                    
                    operationPressed(operation: "-")
                    numberExpected = true
                }
                else if node.name == "times"
                {
//                    print("Touched the times sign")
                    node.isHidden = true
                    equationDisplay.text! = equationDisplay.text! +  " x"
                    run(SKAction.playSoundFileNamed("soundClick.wav", waitForCompletion: false))
                    operatorCount += 1
                    
                    operationPressed(operation: "x")
                    numberExpected = true
                }
                else if node.name == "equals"
                {
//                    print("Touched the equals sign")
                    
                    print("\n When = pressed, operationStack contains \(operationStack) and Operand Stack is \(operandStack)\n")
//  Equals sign not a valid input unless there are at least one operation and at 2 operands on the stack
                    if operationStack.count > 0 && operandStack.count > 1
                    {
                        node.isHidden = true
                        equationDisplay.text! = equationDisplay.text! +  " ="
                        
                        equalsPressed()
                    }
                }
                else if node.name == "move"
                {
//                    print("Touched the move label")
                    digitEntered = false
                    moveRabbit(numSpaces: answer)
                    doMoveSequence()
                    clear()
                    numberExpected = true
                }
            }
            else  // if numberExpected
            {
                if node.name == "firstNumber" || node.name == "secondNumber" || node.name == "thirdNumber"
                {
                        let thisNumber = node as! SKLabelNode
                        digitSelected = Int(thisNumber.text!)!
                        thisNumber.isHidden = true
                        digitPressed(numberPressed: digitSelected)
                        numberExpected = false
                }
            }
                    
            if node.name == "clear"
            {
//                print("Touched the clear label")
                clear()
                numberExpected = true
            }
            else if node.name == "delete"
            {
//                print("Touched the delete label")
                delete()
            // If deleting the 2nd operator, both it and the third operator that was hidden must be restored. Save what the 3rd operator was, or check against operationStack
            }

            if node.name != "delete" && extraOperation == ""
            {
                if plusSprite.isHidden && minusSprite.isHidden
                {
                    timesSprite.isHidden = true
                    extraOperation = "x"
                }
                else if plusSprite.isHidden && timesSprite.isHidden
                {
                    minusSprite.isHidden = true
                    extraOperation = "-"
                }
                else if minusSprite.isHidden && timesSprite.isHidden
                {
                    plusSprite.isHidden = true
                    extraOperation = "+"
                }
            }

        }
    }
    
    func digitPressed(numberPressed: Int)
    {
        run(SKAction.playSoundFileNamed("soundClick.wav", waitForCompletion: false))
//        print("\n Digit pressed is \(numberPressed)\n")
        print("\n Equation is : \(String(describing: equationDisplay.text)) \n")
        equationDisplay.text! = equationDisplay.text! +  " " + String(numberPressed)
        
        // send digit to Calculator
        
        pushOperand(operand: numberPressed)
        
        print("\n Operand Stack is \n \(operandStack) \n")
        digitEntered = true
        clearLabel.isHidden = false
        deleteLabel.isHidden = false
    }

    func operationPressed(operation: String)
    {
        run(SKAction.playSoundFileNamed("soundClick.wav", waitForCompletion: false))
        print("\n Operator sent to Operand Stack is \(operation)\n")
        pushOperation(operation: operation)
    
        print("\n Operation Stack is \n \(operationStack) \n")
    }
    
    func equalsPressed()
    {
        var strAnswer = ""
        answer = 0
        
//        print("Equals pressed; Equation being evaluated.")
        
        run(SKAction.playSoundFileNamed("soundClick.wav", waitForCompletion: false))
        
        answer = evaluateEquation()
        strAnswer = String(answer)
        print("\n\n The answer is \(strAnswer)\n\n")
        equationDisplay.text! = equationDisplay.text! + " " + strAnswer

        hideNumsAndOps()
    }
    
    func clear()
    {
        self.equationDisplay.text = ""
        operandStack.removeAll()
        operationStack.removeAll()
        movesToMake.removeAll()
        showNumsAndOps()
    }
    
    func delete()
    {
        print("\n At start of Delete, extra operation is \(extraOperation) \n")
        if self.equationDisplay.text != nil
        {
            if operandStack.count > operationStack.count  // deleting an operand
            {
                print("\n The number of operands on the stack is \(operandStack.count)\n")
                let poppedOperand = popOperand()
                print("The operand removed was \(poppedOperand)")
                let poppedOperandString = " " + String(poppedOperand)
                self.equationDisplay.text = self.equationDisplay.text?.replacingOccurrences(of: poppedOperandString, with: "")
                
                restoreNumOrOp(value:String(poppedOperand))
                numberExpected = true
            }
            else   // deleting an operator
            {
                if operationStack.count > 0
                {
                    let poppedOperation = popOperation()
                    print("The operation removed was \(poppedOperation)")
                    let poppedOperationString = " " + poppedOperation
                    self.equationDisplay.text = self.equationDisplay.text?.replacingOccurrences(of: poppedOperationString, with: "")
                    
                    restoreNumOrOp(value:poppedOperation) // restore operation to choices
                }

                if extraOperation != ""
                {
                    if extraOperation == "+"
                    {
                        plusSprite.isHidden = false
                    }
                    else if extraOperation == "-"
                    {
                        minusSprite.isHidden = false
                    }
                    else if extraOperation == "x"
                    {
                        timesSprite.isHidden = false
                    }
                    print("\n Extra operation is \(extraOperation) \n")
                    extraOperation = ""
                }
                numberExpected = false
            }
        }
    }
    
    
    func showNumsAndOps()
    {
        firstNum.isHidden = false
        secondNum.isHidden = false
        thirdNum.isHidden = false
        
        plusSprite.isHidden = false
        minusSprite.isHidden = false
        timesSprite.isHidden = false
        equalsSprite.isHidden = false
        
        clearLabel.isHidden = true
        deleteLabel.isHidden = true
        moveLabel.isHidden = true
        
//        extraOperation = ""
    }
    
    func hideNumsAndOps()
    {
        firstNum.isHidden = true
        secondNum.isHidden = true
        thirdNum.isHidden = true
        
        plusSprite.isHidden = true
        minusSprite.isHidden = true
        timesSprite.isHidden = true
        equalsSprite.isHidden = true
        
        clearLabel.isHidden = false
        deleteLabel.isHidden = false
        moveLabel.isHidden = false
        
//        extraOperation = ""
    }
    
    func restoreNumOrOp(value:String)
    {
        if value == firstNum.text
        {
            firstNum.isHidden = false
        }
        else if value == secondNum.text
        {
            secondNum.isHidden = false
        }
        else if value == thirdNum.text
        {
            thirdNum.isHidden = false
        }
        else if value == "+"
        {
            plusSprite.isHidden = false
        }
        else if value == "-"
        {
            minusSprite.isHidden = false
        }
        else if value == "x"
        {
            timesSprite.isHidden = false
        }
    }

    
    func getRandomNumber() -> Int
    {
        let rndOp: Int =  Int(arc4random_uniform(9)+1)    // Generates Number from 1 to 3. Change to (9)+1 in final version!
        
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
        firstNum.text = String(getRandomNumber())

        firstNum.name = "firstNumber"
        firstNum.fontSize = 65
        firstNum.fontColor = .black
        firstNum.horizontalAlignmentMode = .left
        firstNum.position = CGPoint(x: -950, y: -530)
        firstNum.zPosition = 8
        
        addChild(firstNum)
        
        
        secondNum.text = String(getRandomNumber())
        
        secondNum.name = "secondNumber"
        secondNum.fontSize = 65
        secondNum.fontColor = .black
        secondNum.horizontalAlignmentMode = .left
        secondNum.position = CGPoint(x: -750, y: -530)
        secondNum.zPosition = 8


        thirdNum.text = String(getRandomNumber())

        thirdNum.name = "thirdNumber"
        thirdNum.fontSize = 65
        thirdNum.fontColor = .black
        thirdNum.horizontalAlignmentMode = .left
        thirdNum.position = CGPoint(x: -550, y: -530)
        thirdNum.zPosition = 8

        //  Prevent duplicate digits
        // if second operand button same as 1st button, get another digit
        while firstNum.text  == secondNum.text
        {
            secondNum.text = String(getRandomNumber())
        }
        // if third operand button same as 1st or 2nd button, get another digit
        while thirdNum.text == firstNum.text || thirdNum.text == secondNum.text
        {
            thirdNum.text = String(getRandomNumber())
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
        scoreLabel.position = CGPoint(x: -950, y: 502)
        scoreLabel.zPosition = 8
        addChild(scoreLabel)
    }
    
    func setBonusLabel(bonus: String)
    {
        bonusLabel.text = "\(bonus)"
        bonusLabel.fontSize = 65
        //        scoreLabel.fontColor = UIColor(red: 0.0, green: 40.0, blue: 217.0, alpha: 1.0)
//        scoreLabel.fontColor = SKColor(red: 0.1, green: 0.5, blue: 0.0, alpha: 0.0)
        bonusLabel.fontColor = .red
        bonusLabel.horizontalAlignmentMode = .center
        bonusLabel.position = CGPoint(x: 70, y: 502)
        bonusLabel.zPosition = 8
        addChild(bonusLabel)
    }
    
    func setEquationDisplay()
    {
        equationDisplay.text = ""
        equationDisplay.fontSize = 65
        equationDisplay.fontColor = SKColor(red: 0.1, green: 0.5, blue: 1.0, alpha: 1.0)
        equationDisplay.horizontalAlignmentMode = .left
        equationDisplay.position = CGPoint(x: -950, y: -442)
        equationDisplay.zPosition = 8
        addChild(equationDisplay)
    }
    
    func levelUp()
    {
        if level == "Pepper"
        {
            let nextLevel = TeaScene(
        }
    }

} // end of class GameScene

