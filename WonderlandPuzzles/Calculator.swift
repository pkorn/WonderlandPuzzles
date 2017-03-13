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
        var operation: String = operationStack[0]
        
        if operationStack.count > 1
        {
            if (operationStack.removeLast()) == "x"
            {
                let pop1 = popOperand()
                let pop2 = popOperand()
                
                
                result = pop1 * pop2;
                pushOperand(operand: result)
            }
        }
        
        let op1 = operandStack[0]
        let op2 = operandStack[1]
        
        if (operation == "+") {result = op1 + op2}
        else if operation == "x" {result = op1 * op2}
        else if operation == "-" {result = op1 - op2}
        
        if operandStack.count > 2
        {
            let op3 = operandStack[2]
            operation = operationStack[1];
                
            if operation == "+" {result = result + op3}
            else if operation == "x" {result = result * op3}
            else if operation == "-" {result = result - op3}
        }
        return result;
    }





