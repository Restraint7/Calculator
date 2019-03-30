//
//  CalculatorBrain.swift
//  Caculator
//
//  Created by 凯琦牟 on 2017/5/5.
//  Copyright © 2017年 凯琦牟. All rights reserved.
//

import Foundation



struct CalculatorBrain{
    public var description = ""
    public var lastOperation : String?
    private var variable : String?
    private var UnaryOperationDone = false
    
    private var stackOfVariableNumber = [VariableNumber]()
    private var stackOfOperation = [String]()

    mutating func setOperand(_ operand: Double?){
        if UnaryOperationDone {
            description = ""
        }else {
            let emptystack = [variablenumber]()
            stackOfVariableNumber.append(VariableNumber(vairablename: nil, numberpart: operand, variablepart:emptystack,newvariable:nil))
            description = numberFormatter(String(operand!))
        }
    }
    
    mutating func setOperand(_ name: String,factor:Double){
        var stack = [variablenumber]()
        stack.append(variablenumber(factor: factor, indexofvariable: 1.0))
        stackOfVariableNumber.append(VariableNumber(vairablename: name, numberpart: nil, variablepart: stack,newvariable:nil))
        if factor == 1 {
            description = name
        }else {
            description = numberFormatter(String(factor)) + name
        }
    }
    
    func checkWhetherComputedFirst (_ operation:String) -> Bool {
        if stackOfOperation.isEmpty {
            return true
        }else if operations[operation]!.orderOfOperation > operations[stackOfOperation.last!]!.orderOfOperation{
            return true
        }else{
            return false
        }
    }
    
    private mutating func calculate(_ function:Operation) -> VariableNumber {
        switch function {
        case .unaryOperation(let function):
            return function(stackOfVariableNumber.last!)
        case .binaryOperation(let function):
            if stackOfOperation.isEmpty == false {
                let op1 = stackOfVariableNumber.last!
                stackOfVariableNumber.removeLast()
                return function(stackOfVariableNumber.last!,op1)
            }else{
                return stackOfVariableNumber.last!
            }
        default : return stackOfVariableNumber.last!
        }
        
    }
    
    
    mutating func performBinaryOperation(_ symbol: String) {
        
        if lastOperation != nil && (operations[lastOperation!]?.orderOfOperation)! < (operations[symbol]?.orderOfOperation)! {
                description = "(" + description + ")" + symbol
        }else {
            description += symbol
        }
        if stackOfOperation.isEmpty {
            stackOfOperation.append(symbol)
        }else if checkWhetherComputedFirst(symbol){
            stackOfOperation.append(symbol)
        }else {
            if stackOfVariableNumber.last != nil {
                while checkWhetherComputedFirst(symbol) == false && stackOfOperation.isEmpty == false {
                    let result = calculate(operations[(stackOfOperation.last)!]!.function)
                    stackOfVariableNumber.removeLast()
                    stackOfOperation.removeLast()
                    stackOfVariableNumber.append(result)
                }
                stackOfOperation.append(symbol)
            }
        }
        UnaryOperationDone = false
}

    mutating func performUnaryOperation(_ symbol: String){
        if lastOperation != nil {
            description = symbol + "(" + description + ")"
        }else{
            description = symbol + description
        }
        let result = calculate(operations[symbol]!.function)
        stackOfVariableNumber.removeLast()
        stackOfVariableNumber.append(result)
        UnaryOperationDone = true
    }

    mutating func equal(){
        while stackOfOperation.isEmpty == false {
            lastOperation = stackOfOperation.last!
            let result = calculate(operations[(stackOfOperation.last)!]!.function)
            stackOfOperation.removeLast()
            stackOfVariableNumber.removeLast()
            stackOfVariableNumber.append(result)
        }
        UnaryOperationDone = false
        
    }
    


    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        
        return (0,false,"")
    }

    var result:VariableNumber? {
        get{
            return stackOfVariableNumber.last!
        }
    }
    
    
}


/**

struct CalculatorBrain{
    
    public var resultIsPending = false 
    private var preOperation : Int? , currentOperation : Int?
    public var description = ""
    private var accumulator: Double?
    public var resultHasComputed = false
    private var accumularIsConstant = false
    private var lastNumber : String?
    
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double,Double)->Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos":  Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation({ -$0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals
    ]
    
    
    mutating func performOperation (_ symbol:String){
        
        if let operation = operations[symbol] {
            
            if (symbol == "+" || symbol == "−") {
                currentOperation = 1
            }
            else if (symbol == "×" || symbol == "÷" ) {
                currentOperation = 2
            }
            else if (symbol == "√" || symbol == "cos" ) {
                currentOperation = 3
            }
            else{
                currentOperation = 0
            }

            switch operation{
            case .constant(let value):
                accumulator = value
                accumularIsConstant = true
                lastNumber = symbol
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    if preOperation != nil && resultIsPending == false {
                        description = symbol + "(" + description + ")"
                    }else if accumularIsConstant == false{
                        description = description + symbol + numberFormatter(String(accumulator!))
                    }else{
                        description = description + symbol + lastNumber!
                    }
                    accumulator = function(accumulator!)
                    resultHasComputed = true
                    accumularIsConstant = false
                }
                
            case .binaryOperation(let function):
                if accumulator != nil {
                    if (resultIsPending || resultHasComputed == false) {
                        if accumularIsConstant{
                            description += lastNumber!
                        }else{
                            description += numberFormatter(String(accumulator!))
                        }
                    }else if currentOperation! > preOperation! {
                        description = "(" + description + ")"
                    }
                    description += symbol
                    if resultIsPending {
                        if currentOperation! == preOperation!{
                            performPendingBinaryOperation()
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                        }
                        if currentOperation! > preOperation! {
                            pendingFirstNumber = pendingBinaryOperation
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                            accumulator = nil
                        }
                        if currentOperation! < preOperation! {
                            performPendingBinaryOperation()
                            if pendingFirstNumber != nil {
                                accumulator = pendingFirstNumber?.perform(with: accumulator!)
                                pendingFirstNumber = nil
                            }
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                        }
                    }else{
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                        resultIsPending = true
                    }
                    accumularIsConstant = false
                }else if pendingBinaryOperation != nil{
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: (pendingBinaryOperation?.firstOperand)!)
                    description = deleteLastCharacter(description)
                    description += symbol
                }
                
                
            case .equals:
                if accumulator != nil {
                    if accumularIsConstant {
                        description += lastNumber!
                    }else if preOperation! < 3 {
                        description += numberFormatter(String(accumulator!))
                    }
                }
                performPendingBinaryOperation()
                if pendingFirstNumber != nil && accumulator != nil {
                    accumulator = pendingFirstNumber?.perform(with: accumulator!)
                    pendingFirstNumber = nil
                }
                resultIsPending = false
                resultHasComputed = true
            }
            preOperation = currentOperation
        }
    }
    
    private mutating func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func deleteLastCharacter (_ string: String) -> String{
        let endindex = string.endIndex
        let startindex = string.index(endindex, offsetBy: -1)
        var changedstring = string
        changedstring.removeSubrange(startindex..<endindex)
        return changedstring
    }
    
    private var pendingBinaryOperation:PendingBinaryOperation?
    private var pendingFirstNumber:PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) ->Double{
            return function(firstOperand,secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double?){
        accumulator = operand
    }
    
    var result:Double? {
        get{
            return accumulator
        }
    }

*/
