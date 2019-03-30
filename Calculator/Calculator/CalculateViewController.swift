 //
//  ViewController.swift
//  Caculator
//
//  Created by 凯琦牟 on 2017/4/21.
//  Copyright © 2017年 凯琦牟. All rights reserved.
//

import UIKit

class CalculateViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var display_sequence: UILabel!
    @IBOutlet weak var graphButton: UIButton! {
        didSet{
            graphButton.isEnabled = false
            graphButton.backgroundColor = UIColor.lightGray
        }
    }
    
    
    var userIsInTheMiddleOfTyping = false
    var dotHasExist = false
    var preSequence = ""
    var userFirstTyping = true
    var computeFinished = false
    var lastInputIsVariable = false
    
    private func cleaerAll () {
        display.text = "0"
        display_sequence.text = "0"
        userIsInTheMiddleOfTyping = false
        userFirstTyping = true
        preSequence = ""
        lastInputIsVariable = false
        brain = CalculatorBrain()
        graphButton.isEnabled = false
        graphButton.backgroundColor = UIColor.lightGray
    }
   
    @IBAction func touchDigit(_ sender: UIButton) {
        if lastInputIsVariable || computeFinished {
            cleaerAll()
            computeFinished = false
        }
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurretlyInDisplay = display.text!
            display.text = textCurretlyInDisplay + digit
        }else{
            
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        if userFirstTyping{
            display_sequence.text = digit
            userFirstTyping = false
        }else{
            let textCurrentlyInDisplaySequence = display_sequence.text!
            display_sequence.text = textCurrentlyInDisplaySequence + digit
        }
        
    }

    @IBAction func inputVariable(_ sender: UIButton) {
        if computeFinished {
            cleaerAll()
            computeFinished = false
        }
        if userIsInTheMiddleOfTyping{
            if let factor = Double(displayValue) {
                brain.setOperand(sender.currentTitle!,factor: factor)
            }
            display.text! += sender.currentTitle!
            display_sequence.text! += sender.currentTitle!
        }else {
            if lastInputIsVariable == false {
                display.text = sender.currentTitle!
                if userFirstTyping{
                    display_sequence.text = sender.currentTitle!
                    userFirstTyping = false
                }else{
                    display_sequence.text = (display_sequence.text ?? "") + sender.currentTitle!
                }
                
            }
            brain.setOperand(sender.currentTitle!,factor: 1.0)
        }
        lastInputIsVariable = true
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        cleaerAll()
    }
    
    @IBAction func appenddot(_ sender: UIButton) {
        if dotHasExist != true {
            if userIsInTheMiddleOfTyping {
                let textCurretlyInDisplay = display.text!
                display.text = textCurretlyInDisplay + "."
                display_sequence.text! += "."
            }else{
                display.text = "0."
                userIsInTheMiddleOfTyping = true
                display_sequence.text = "0."
            }
            dotHasExist = true
        }
    }
    
    var displayValue: String {
        get{
            return display.text!
        }
        set{
            display.text = newValue
        }
    }
    
    var brain = CalculatorBrain()
    
    
    private func setDisplayBeforeCompute (){
        if userIsInTheMiddleOfTyping {
            if lastInputIsVariable == false {
                if let number = Double(displayValue) {
                    brain.setOperand(number)
                }
            }
            userIsInTheMiddleOfTyping = false
            lastInputIsVariable = false
        }else{
            if display_sequence.text! != "0" {
                if let number = Double(displayValue) {
                    brain.setOperand(number)
                }
                brain.description = display_sequence.text!
            }else {
                displayValue = "0"
                if let number = Double(displayValue) {
                    brain.setOperand(number)
                }
            }
        }
    }
    
    private func setDisplayAfterCompute () {
        if let result = brain.result {
            displayValue = showResult(result)!
        }
        display_sequence.text! = preSequence + brain.description
        preSequence = display_sequence.text!
        lastInputIsVariable = false
        dotHasExist = false
        computeFinished = false
    }
    
    @IBAction func performBinaryOperation(_ sender: UIButton) {
        setDisplayBeforeCompute()
        if let mathematicalSymbol = sender.currentTitle{
            brain.performBinaryOperation(mathematicalSymbol)
        }
        setDisplayAfterCompute()
    }
    
    @IBAction func performUnaryOperation(_ sender: UIButton) {
        setDisplayBeforeCompute()
        if let mathematicalSymbol = sender.currentTitle{
            brain.performUnaryOperation(mathematicalSymbol)
        }
        setDisplayAfterCompute()
        brain.description = ""
        userIsInTheMiddleOfTyping = true
        if brain.result?.variablepart.isEmpty == false {
            graphButton.isEnabled = true
            graphButton.backgroundColor = UIColor.groupTableViewBackground
        }
    }

    
    
    @IBAction func performEqual(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping || lastInputIsVariable {
            if lastInputIsVariable == false {
                if let number = Double(displayValue) {
                    brain.setOperand(number)
                }
            }
            brain.equal()
            if let result = brain.result {
                displayValue = showResult(result)!
            }
            display_sequence.text! = preSequence + brain.description
            preSequence = ""
            dotHasExist = false
            computeFinished = true
            userIsInTheMiddleOfTyping = false
        }
        if brain.result?.variablepart.isEmpty == false {
            graphButton.isEnabled = true
            graphButton.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController{
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let graphViewController = destinationViewController as? GraphViewController{
            graphViewController.result = brain.result!
        }
    }
    
 }
    /*
     @IBAction func Backspace(_ sender: UIButton) {
        if nextSupposedToBeANumber == false {
            display.text! = brain.deleteLastCharacter(display.text!)
            display_sequence.text! = brain.deleteLastCharacter(display_sequence.text!)
        }
    }
    */

 


 
