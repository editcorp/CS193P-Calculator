//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael L Gueterman on 3/29/17.
//  Copyright © 2017 Michael L Gueterman. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private var accumulator: Double?
    private var _description: String? = nil
    private var _resultIsPending = false
    private var _priorOperation: String? = nil
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
        case randomValue
    }
    
    private var operations: Dictionary<String, Operation> =
        [
            "π": Operation.constant(Double.pi),
            "e": Operation.constant(M_E),
            "√": Operation.unaryOperation(sqrt),
            "sin": Operation.unaryOperation (cos),
            "cos": Operation.unaryOperation (cos),
            "±": Operation.unaryOperation({-$0}),
            "×": Operation.binaryOperation({$0 * $1}),
            "÷": Operation.binaryOperation({$0 / $1}),
            "+": Operation.binaryOperation({$0 + $1}),
            "−": Operation.binaryOperation({$0 - $1}),
            "=": Operation.equals,
            "C": Operation.clear,
            "🎲": Operation.randomValue
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            // Format the number to a minimum of zero and maximum of 6 decimal places.
            let sixDigitFormatter = NumberFormatter()
            sixDigitFormatter.numberStyle = .decimal
            sixDigitFormatter.minimumFractionDigits = 0
            sixDigitFormatter.maximumFractionDigits = 6

            // Perform the appropriate logic based on the button that was pressed.
            switch operation {
            case .constant(let value):
                accumulator = value
                if _description != nil {
                    _description = _description! + " " + symbol
                } else {
                    _description = symbol
                }
                _priorOperation = "constant"
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    if _description != nil && _resultIsPending == false {
                        _description = symbol + "(" + _description! + ")"
                    } else if _description != nil {
                        _description = _description! + " " + symbol + "(" + sixDigitFormatter.string(from: NSNumber(value: accumulator!))! + ")"
                    } else {
                        _description = symbol + "(" + sixDigitFormatter.string(from: NSNumber(value: accumulator!))! + ")"
                    }
                    accumulator = function(accumulator!)
                    _priorOperation = "unary"
                }
                
            case .binaryOperation(let function):
                if accumulator != nil {
                    if _description != nil {
                        _description = _description! + " " + symbol
                    } else {
                        _description = sixDigitFormatter.string(from: NSNumber(value: accumulator!))! + " " + symbol
                    }
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    _resultIsPending = true
                    _priorOperation = "binary"
                }
                
            case .equals:
                if accumulator != nil {
                    if _description != nil && _priorOperation == "binary" {
                        _description = _description! + " " + sixDigitFormatter.string(from: NSNumber(value: accumulator!))!
                    }
                    performPendingBinaryOperation()
                    _resultIsPending = false
                    _priorOperation = "equals"
                }
                
            case .clear:
                performClear()
                _description = nil
                _resultIsPending = false
                _priorOperation = "clear"

            case .randomValue:
                performCreateRandomValue()
                _priorOperation = "randomValue"

            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    private mutating func performClear() {
        pendingBinaryOperation = nil
        accumulator = 0.0
     }

    private mutating func performCreateRandomValue() {
        // Generate a random number from 0 to 999999, then shift the decimal point to the left by six places.
        accumulator = Double(arc4random_uniform(999999)) * 1.0e-6
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool? {
        get {
            return _resultIsPending
        }
    }

    var description: String? {
        get {
            return _description
        }
    }
    
}
