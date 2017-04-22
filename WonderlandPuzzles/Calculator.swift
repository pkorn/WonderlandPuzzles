//
//  Calculator.swift
//  WonderlandPuzzles
//
//  Created by Patricia Korn on 2/26/17.
//  Copyright © 2017 Patricia Korn. All rights reserved.
//

import Foundation

//
//  Brain.m
//  DownTheRabbitHole
//
//  Created by Patricia Korn on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

var operandStack = [Int]()
var operationStack = [String]()
var operand: Int = 0
var buttonStack = [String]()
var scoreStore = [Int]()

    func pushOperand(operand: Int)
    {
        operandStack.append(operand)
    }
    
    func pushButton(aButton: String)
    {
        buttonStack.append(aButton)
    }


    func pushOperation(operation: String)
    {
        operationStack.append(operation)
    }
    
    func popOperand() -> Int
    {
        return operandStack.removeLast()
    }

    func popOperation() -> String
    {
        return operationStack.removeLast()
    }
            
   func popButton() -> String
   {
        return buttonStack.removeLast()
   }



   func evaluateEquation() -> Int
    {
        var result: Int = 0
        var thisOperation: String = ""
        
        print ("\n Operation Stack in evaluateEquation is \(operationStack)\n")
        print ("\n First element of Operation Stack in evaluateEquation is \(operationStack[0])\n")
        thisOperation = operationStack[0]
        
        if operationStack.count > 1
        {
            if (operationStack[operationStack.count - 1]) == "x"
            {
                let pop1 = popOperand()
                let pop2 = popOperand()
                
                
                result = pop1 * pop2;
                pushOperand(operand: result)
            }
        }
        
        let op1 = operandStack[0]
        let op2 = operandStack[1]
        
        if (thisOperation == "+") {result = op1 + op2}
        else if thisOperation == "x" {result = op1 * op2}
        else if thisOperation == "-" {result = op1 - op2}
        
        if operandStack.count > 2
        {
            let op3 = operandStack[2]
            thisOperation = operationStack[1];
                
            if thisOperation == "+" {result = result + op3}
            else if thisOperation == "x" {result = result * op3}
            else if thisOperation == "-" {result = result - op3}
        }
        return result;
    }





