//
//  ViewController.swift
//  Calculator
//
//  Created by Michael L Gueterman on 3/29/17.
//  Copyright © 2017 Michael L Gueterman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var runningDescription: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //Add the digit to the display, but do not allow multiple decimal points to be entered.
            if digit != "." || ((digit == ".") && !textCurrentlyInDisplay.contains(".")) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping && (display.text?.characters.count)! > 0 {
            display.text?.characters.removeLast()
            if display.text?.characters.count == 0 {
                userIsInTheMiddleOfTyping = false
                display.text = "0"
            }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            // Format the number to a minimum of zero and maximum of 6 decimal places.
            let sixDigitFormatter = NumberFormatter()
            sixDigitFormatter.numberStyle = .decimal
            sixDigitFormatter.minimumFractionDigits = 0
            sixDigitFormatter.maximumFractionDigits = 6
            display.text = sixDigitFormatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain = CalculatorBrain()
    private var tempStr: String?
    private var desc = ""
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            displayValue = result
        }

        if brain.resultIsPending == true && brain.description != nil {
            tempStr = brain.description! + " ..."
        } else if brain.description != nil {
            tempStr = brain.description! + " ="
        } else {
            tempStr = ""
        }
        // Display the running Description
        runningDescription.text = tempStr!
    }
}

