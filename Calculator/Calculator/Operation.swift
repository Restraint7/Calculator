//
//  Operation.swift
//  Caculator
//
//  Created by 凯琦牟 on 2017/7/16.
//  Copyright © 2017年 凯琦牟. All rights reserved.
//

import Foundation

struct variablenumber {
    var factor:Double
    var indexofvariable:Double
}

struct VariableNumber{
    var vairablename:String?
    var numberpart:Double?
    var variablepart = [variablenumber]()
    var newvariable:String?
}

var constant : Dictionary<String,Double> = [
    "π" : Double.pi,
    "e" : M_E
]

enum Operation{
    case unaryOperation((VariableNumber)->VariableNumber)
    case binaryOperation((VariableNumber,VariableNumber)->VariableNumber)
    case other
}

var operations: Dictionary<String,(orderOfOperation:Int,function:Operation)> = [
    "√" : (3,Operation.unaryOperation(sqrt)),
    "cos": (3,Operation.other),
    "±" : (3,Operation.other),
    "×" : (2,Operation.binaryOperation({ $0 * $1 })),
    "÷" : (2,Operation.binaryOperation({ $0 / $1 })),
    "+" : (1,Operation.binaryOperation({ $0 + $1 })),
    "−" : (1,Operation.binaryOperation({ $0 - $1 })),
    "(" : (4,Operation.other),
    ")" : (0,Operation.other)
]


func sqrt (op:VariableNumber) -> VariableNumber {
    var result = VariableNumber(vairablename: op.vairablename, numberpart: nil, variablepart: [variablenumber](),newvariable:nil)
    if op.numberpart != nil && op.variablepart.isEmpty{
        result.numberpart = sqrt(op.numberpart!)
    }
    if op.numberpart == nil && op.variablepart.count < 2{
        result.variablepart.append(variablenumber(factor: sqrt(op.variablepart[0].factor), indexofvariable: op.variablepart[0].indexofvariable * 0.5))
    }
    if (op.numberpart != nil && op.variablepart.isEmpty == false) || op.numberpart == nil && op.variablepart.count > 1 {
        result.vairablename = "(" + showResult(op)! + ")"
        result.variablepart.append(variablenumber(factor: 1.0, indexofvariable: 0.5))
    }
    return result
}

func < (op1:variablenumber,op2:variablenumber) ->Bool {
    if op1.indexofvariable < op2.indexofvariable{
        return true
    }else {
        return false
    }
}



func * (op1:VariableNumber,op2:VariableNumber) -> VariableNumber{
    var result = VariableNumber(vairablename: nil, numberpart: nil, variablepart: [variablenumber](),newvariable:nil)
    var array1 = [variablenumber]()
    var array2 = [variablenumber]()
    var array3 = [variablenumber]()
    if op1.vairablename != nil {
        result.vairablename = op1.vairablename!
    }else if op2.vairablename != nil {
        result.vairablename = op2.vairablename!
    }else {
        result.vairablename = nil 
    }
    
    if op1.numberpart != nil && op2.numberpart != nil {
        result.numberpart = op1.numberpart! * op2.numberpart!
    }
    if op1.numberpart != nil && op2.variablepart.isEmpty == false{
        for variable in op2.variablepart {
            let newvariable = variablenumber(factor: op1.numberpart!*variable.factor, indexofvariable: variable.indexofvariable)
            array1.append(newvariable)
        }
        array1.sort(by: <)
        result.variablepart += array1
    }
    if op2.numberpart != nil && op1.variablepart.isEmpty == false{
        for variable in op1.variablepart {
            let newvariable = variablenumber(factor: op2.numberpart!*variable.factor, indexofvariable: variable.indexofvariable)
            array2.append(newvariable)
        }
        array2.sort(by: <)
        result.variablepart += array2
    }
    if op1.variablepart.isEmpty == false && op2.variablepart.isEmpty == false{
        for (_,variable) in op1.variablepart.enumerated(){
            var array = [variablenumber]()
            for (_,variable1) in op2.variablepart.enumerated(){
                let newvariable = variablenumber(factor: variable.factor*variable1.factor, indexofvariable: variable.indexofvariable+variable1.indexofvariable)
                if newvariable.indexofvariable == 0 {
                    result.numberpart = (result.numberpart ?? 0.0) + newvariable.factor
                }else {
                    array.append(newvariable)
                }
            }
            array3 += array
        }
        array3.sort(by: <)
        result.variablepart += array3
    }
    return result
}

func / (op1:VariableNumber,op2:VariableNumber) -> VariableNumber{
    var result = VariableNumber(vairablename: nil, numberpart: nil, variablepart: [variablenumber](),newvariable:nil)
    var array1 = [variablenumber]()
    var array2 = [variablenumber]()
    var array3 = [variablenumber]()
    if op1.vairablename != nil {
        result.vairablename = op1.vairablename!
    }else if op2.vairablename != nil {
        result.vairablename = op2.vairablename!
    }else {
        result.vairablename = nil
    }
    
    if op1.numberpart != nil && op2.numberpart != nil {
        result.numberpart = op1.numberpart! / op2.numberpart!
    }
    if op1.numberpart != nil && op2.variablepart.isEmpty == false{
        for variable in op2.variablepart {
            let newvariable = variablenumber(factor: op1.numberpart!/variable.factor, indexofvariable: -variable.indexofvariable)
            array1.append(newvariable)
        }
        array1.sort(by: <)
        result.variablepart += array1
    }
    if op2.numberpart != nil && op1.variablepart.isEmpty == false{
        for variable in op1.variablepart {
            let newvariable = variablenumber(factor: variable.factor/op2.numberpart!, indexofvariable: variable.indexofvariable)
            array2.append(newvariable)
        }
        array2.sort(by: <)
        result.variablepart += array2
    }
    if op1.variablepart.isEmpty == false && op2.variablepart.isEmpty == false{
        for (_,variable) in op1.variablepart.enumerated(){
            var array = [variablenumber]()
                let newvariable = variablenumber(factor: variable.factor / op2.variablepart[0].factor, indexofvariable: variable.indexofvariable - op2.variablepart[0].indexofvariable)
                if newvariable.indexofvariable == 0 {
                    result.numberpart = (result.numberpart ?? 0.0) + newvariable.factor
                }else {
                    array.append(newvariable)
            }
            array3 += array
        }
        array3.sort(by: <)
        result.variablepart += array3
    }
    return result
}

func + (op1:VariableNumber,op2:VariableNumber) -> VariableNumber{
    var result = VariableNumber(vairablename: nil, numberpart: nil, variablepart: [variablenumber](),newvariable:nil)
    if op1.vairablename != nil {
        result.vairablename = op1.vairablename!
    }else if op2.vairablename != nil {
        result.vairablename = op2.vairablename!
    }else {
        result.vairablename = nil
    }
    if let number = op1.numberpart {
        result.numberpart = (result.numberpart ?? 0.0) + number
    }
    if let number = op2.numberpart{
        result.numberpart = (result.numberpart ?? 0.0) + number
    }
    result.variablepart = op1.variablepart + op2.variablepart
    return result
}

func - (op1:VariableNumber,op2:VariableNumber) -> VariableNumber{
    var result = VariableNumber(vairablename: nil, numberpart: nil, variablepart: [variablenumber](),newvariable:nil)
    if op1.vairablename != nil {
        result.vairablename = op1.vairablename!
    }else if op2.vairablename != nil {
        result.vairablename = op2.vairablename!
    }else {
        result.vairablename = nil
    }
    if let number = op1.numberpart {
        result.numberpart = (result.numberpart ?? 0.0) + number
    }
    if let number = op2.numberpart{
        result.numberpart = (result.numberpart ?? 0.0) - number
    }
    result.variablepart = op1.variablepart - op2.variablepart
    return result
}

func + (op1:[variablenumber],op2:[variablenumber]) -> [variablenumber]{
    var result = [variablenumber]()
    if op1.isEmpty && op2.isEmpty == false {
        result = op2
    }
    if op1.isEmpty == false && op2.isEmpty {
        result = op1
    }
    if op1.isEmpty == false && op2.isEmpty == false {
        var i = 0
        var j = 0
        if op1[0].indexofvariable < op2[0].indexofvariable {
            result.append(op1[0])
            i += 1
        }else {
            result.append(op2[0])
            j += 1
        }
        while i < op1.count && j < op2.count {
            if op1[i].indexofvariable < op2[j].indexofvariable {
                if result.last!.indexofvariable == op1[i].indexofvariable {
                    let sum = result.last!.factor + op1[i].factor
                    result.removeLast()
                    if sum != 0 {
                        result.append(variablenumber(factor: sum, indexofvariable: op1[i].indexofvariable))
                    }
                }else {
                    result.append(op1[i])
                }
                i += 1
            }else {
                if result.last!.indexofvariable == op2[j].indexofvariable {
                    let sum = result.last!.factor + op2[j].factor
                    result.removeLast()
                    if sum != 0 {
                        result.append(variablenumber(factor: sum, indexofvariable: op2[j].indexofvariable))
                    }
                }else {
                    result.append(op2[j])
                }
                j += 1
            }
        }
        while i < op1.count {
            if result.last!.indexofvariable == op1[i].indexofvariable {
                let sum = result.last!.factor + op1[i].factor
                result.removeLast()
                if sum != 0 {
                    result.append(variablenumber(factor: sum, indexofvariable: op1[i].indexofvariable))
                }
            }else {
                result.append(op1[i])
            }
            i += 1
        }
        while j < op2.count{
            if result.last!.indexofvariable == op2[j].indexofvariable {
                let sum = result.last!.factor + op2[j].factor
                result.removeLast()
                if sum != 0 {
                    result.append(variablenumber(factor: sum, indexofvariable: op2[j].indexofvariable))
                }
            }else {
                result.append(op2[j])
            }
            j += 1
        }
    }
    return result
}


func - (op1:[variablenumber],op2:[variablenumber]) -> [variablenumber]{
    var result = [variablenumber]()
    if op1.isEmpty && op2.isEmpty == false {
        for variable in op2{
            result.append(variablenumber(factor: -variable.factor, indexofvariable: variable.indexofvariable))
        }
    }
    if op1.isEmpty == false && op2.isEmpty {
        result = op1
    }
    if op1.isEmpty == false && op2.isEmpty == false {
        var i = 0
        var j = 0
        if op1[0].indexofvariable < op2[0].indexofvariable {
            result.append(op1[0])
            i += 1
        }else {
            result.append(variablenumber(factor: -op2[0].factor, indexofvariable: op2[0].indexofvariable))
            j += 1
        }
        while i < op1.count && j < op2.count {
            if op1[i].indexofvariable < op2[j].indexofvariable {
                if result.last!.indexofvariable == op1[i].indexofvariable {
                    let sum = result.last!.factor + op1[i].factor
                    result.removeLast()
                    if sum != 0 {
                        result.append(variablenumber(factor: sum, indexofvariable: op1[i].indexofvariable))
                    }
                }else {
                    result.append(op1[i])
                }
                i += 1
            }else {
                if result.last!.indexofvariable == op2[j].indexofvariable {
                    let sum = result.last!.factor - op2[j].factor
                    result.removeLast()
                    if sum != 0 {
                        result.append(variablenumber(factor: sum, indexofvariable: op2[j].indexofvariable))
                    }
                }else {
                    result.append(variablenumber(factor: -op2[j].factor, indexofvariable: op2[j].indexofvariable))
                }
                j += 1
            }
        }
        while i < op1.count {
            if result.last!.indexofvariable == op1[i].indexofvariable {
                let sum = result.last!.factor + op1[i].factor
                result.removeLast()
                if sum != 0 {
                    result.append(variablenumber(factor: sum, indexofvariable: op1[i].indexofvariable))
                }
            }else {
                result.append(op1[i])
            }
            i += 1
        }
        while j < op2.count{
            if result.last!.indexofvariable == op2[j].indexofvariable {
                let sum = result.last!.factor - op2[j].factor
                result.removeLast()
                if sum != 0 {
                    result.append(variablenumber(factor: sum, indexofvariable: op2[j].indexofvariable))
                }
            }else {
                result.append(variablenumber(factor: -op2[j].factor, indexofvariable: op2[j].indexofvariable))
            }
            j += 1
        }
    }
    return result
}

func showResult (_ resultNumber:VariableNumber) -> String? {
    var result = ""
    var needplussymbol = false
    if let numberpart = resultNumber.numberpart {
        result = numberFormatter(String(numberpart))
        if resultNumber.variablepart.isEmpty == false {
            result += "+"
        }
    }
    for variable in resultNumber.variablepart{
        if needplussymbol {
            result += "+"
        }
        if variable.factor != 1.0{
            result += numberFormatter(String(variable.factor))
        }
        result += resultNumber.vairablename!
        if variable.indexofvariable != 1.0 {
            if abs(variable.indexofvariable) < 1{
                result += "^0" + numberFormatter(String(variable.indexofvariable))
            }else {
                result += "^" + numberFormatter(String(variable.indexofvariable))
            }
        }
        needplussymbol = true
    }
    needplussymbol = false
    if result == "" {
        result = "0"
    }
    return result
}

func calculateResult(_ resultNumber:VariableNumber,variableValue:Double) -> Double? {
    if resultNumber.variablepart.isEmpty{
        return resultNumber.numberpart
    }else {
        var result = resultNumber.numberpart
        for variable in resultNumber.variablepart{
            result = (result ?? 0.0) + variable.factor * pow(variableValue,variable.indexofvariable)
        }
        return result
    }
}

func numberFormatter (_ numberstring:String) -> String{
    let number = NSNumber(value: Double(numberstring) ?? 0 )
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 6
    formatter.minimumFractionDigits = 0
    if abs(Double(numberstring)!) < 1{
        return "0" + (formatter.string(from: number) ?? "")
    }else {
        return formatter.string(from: number) ?? ""
    }
}



/*
func * (op1:variableNumber,op2:variableNumber) -> variableNumber{
    let newvariable = variableNumber(factor: op1.factor*op2.factor,indexofvariable: op1.indexofvariable + op2.indexofvariable)
    return newvariable
}




func * (op1:Double,op2:variableNumber) -> variableNumber{
    let newvariable = variableNumber(factor: op1*op2.factor, indexofvariable: op2.indexofvariable)
    return newvariable
}
 
func / (op1:variableNumber,op2:variableNumber) -> variableNumber{
    let newvariable = variableNumber(factor: op1.factor/op2.factor,indexofvariable: op1.indexofvariable - op2.indexofvariable)
    return newvariable
}


func / (op1:[variableNumber],op2:variableNumber) -> [variableNumber]{
    var variable = op2
    variable.indexofvariable = -op2.indexofvariable
    return op1 * variable
}

func / (op1:[variableNumber],op2:Double) -> [variableNumber]{
    var result = op1
    for (index,_) in result.enumerated() {
        result[index].factor /= op2
    }
    return result
}

func / (op1:Double,op2:variableNumber) -> variableNumber{
    let newvariable = variableNumber(factor: op1/op2.factor, indexofvariable: -op2.indexofvariable)
    return newvariable
}

func + (op1:[variableNumber],op2:Double) -> (variable:[variableNumber],number:Double){
    return (op1,op2)
}

func + (op1:[variableNumber],op2:variableNumber) -> [variableNumber]{
    var result = op1
    var variableAdded = false
    for (index,variable) in op1.enumerated(){
        if variable.indexofvariable == op2.indexofvariable{
            result[index].factor += op2.factor
            if result[index].factor == 0 {
                result.remove(at: index)
            }
            variableAdded = true
        }
    }
    if variableAdded == false {
        result.append(op2)
        result.sort(by: >)
    }
    return result
}

func - (op1:[variableNumber],op2:variableNumber) -> [variableNumber]{
    var variable = op2
    variable.factor = -op2.factor
    return (op1+variable)
}

 enum operationOfVariable{
 case unaryOperation
 case binaryOperation((Double?,variableNumberStack,variableNumber?) -> variableNumberStack)
 case other
 }
 
 var operationsofvariable: Dictionary<String,(orderOfOperation:Int,function:operationOfVariable)> = [
 "√" : (3,operationOfVariable.other),
 "cos": (3,operationOfVariable.other),
 "±" : (3,operationOfVariable.other),
 "×" : (2,operationOfVariable.binaryOperation(multiply)),
 "÷" : (2,operationOfVariable.other),
 "+" : (1,operationOfVariable.binaryOperation(add)),
 "−" : (1,operationOfVariable.other),
 "(" : (4,operationOfVariable.other),
 ")" : (0,operationOfVariable.other)
 
 ]
 
 func * (op1:VariableNumber,op2:Double) -> VariableNumber{
 var result = op1
 if result.numberpart != nil {
 result.numberpart! *= op2
 }
 for (index,_) in result.variablepart.enumerated() {
 result.variablepart[index].factor *= op2
 }
 return result
 
 }
 
 func * (op1:VariableNumber,op2:variablenumber) -> VariableNumber{
 var result = op1
 for (index,_) in result.variablepart.enumerated() {
 result.variablepart[index].indexofvariable += op2.indexofvariable
 }
 if op1.numberpart != nil{
 let newvariable = variablenumber(factor: op1.numberpart! * op2.factor, indexofvariable: op2.indexofvariable)
 result.variablepart.append(newvariable)
 result.variablepart.sort(by: >)
 }
 return result
 }
 
 
 func * (op1:Double,op2:variablenumber) -> variablenumber{
 let result = variablenumber(factor: op1 * op2.factor, indexofvariable: op2.indexofvariable)
 return result
 }
 
 
 func + (op1:VariableNumber,op2:variablenumber) -> VariableNumber{
 var result = op1
 var variableIndexIsSame = false
 for (index,variableinstack) in result.variablepart.enumerated() {
 if variableinstack.indexofvariable == op2.indexofvariable{
 result.variablepart[index].factor += op2.factor
 variableIndexIsSame = true
 break
 }
 }
 if variableIndexIsSame == false {
 result.variablepart.append(op2)
 result.variablepart.sort(by: >)
 }
 return result
 }
 
 func + (op1:VariableNumber,op2:Double) -> VariableNumber{
 var result = op1
 result.numberpart = (op1.numberpart ?? 0.0) + op2
 return result
 
 }
 
 
 func + (op1:VariableNumber,op2:VariableNumber) -> VariableNumber{
 var result = op1
 if op1.numberpart != nil || op2.numberpart != nil {
 result.numberpart = (op1.numberpart ?? 0.0) + (op2.numberpart ?? 0.0)
 }
 for (_,variableinstack) in op2.variablepart.enumerated() {
 result = result + variableinstack
 }
 return result
 }


*/
