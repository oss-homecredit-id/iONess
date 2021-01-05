//
//  Thenable.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Thenable protocol
/// This protocol are designed to run the thenable closure after doing some task which produced Result and Dropable object
public protocol Thenable {
    associatedtype Result
    associatedtype DropablePromise: Dropable
    
    /// Method to run task and then running closures passed
    /// - Parameters:
    ///   - closure: closure which will be run when task succeed
    ///   - failClosure: closure which will be run when task fail
    @discardableResult
    func then(run closure: @escaping (Result) -> Void, whenFailed failClosure: @escaping (Result) -> Void) -> DropablePromise
    
    /// Method to run task and then running closure passed
    /// - Parameter closure: closure which will be run when task finished
    @discardableResult
    func then(run closure: @escaping (Result) -> Void) -> DropablePromise
    
    /// Method to run task and then running closures passed
    /// - Parameters:
    ///   - closure: closure which will be run when task succeed
    ///   - failClosure: closure which will be run when task fail
    ///   - deferClosure: closure which will be run after closure or failClosure
    @discardableResult
    func then(run closure: @escaping (Result) -> Void, whenFailed failClosure: @escaping (Result) -> Void, finally deferClosure: @escaping (Result) -> Void) -> DropablePromise
    
    
    /// Method to execute request and then run any method passed
    /// - Parameters:
    ///   - observer: object that observe request
    ///   - method: observer method to call when request completed
    @discardableResult
    func then<Observer: AnyObject>(observing observer: Observer, call method: @escaping (Observer) -> ((Result) -> Void)) -> DropablePromise
    
    /// Method to execute request and then run any method passed
    /// - Parameters:
    ///   - observer: object that observe request
    ///   - method: observer method to call when succeed
    ///   - failMethod: observer method to call when fail
    @discardableResult
    func then<Observer: AnyObject>(observing observer: Observer, call method: @escaping (Observer) -> ((Result) -> Void), whenFailedCall failMethod: @escaping (Observer) -> ((Result) -> Void)) -> DropablePromise
    
    /// Method to execute request and then run any method passed
    /// - Parameters:
    ///   - observer: object that observe request
    ///   - method: observer method to call when succeed
    ///   - failMethod: observer method to call when fail
    ///   - finalMethod: observer method to call when request completed
    @discardableResult
    func then<Observer: AnyObject>(observing observer: Observer, call method: @escaping (Observer) -> ((Result) -> Void), whenFailedCall failMethod: @escaping (Observer) -> ((Result) -> Void), finallyCall finalMethod: @escaping (Observer) -> ((Result) -> Void)) -> DropablePromise
}

public extension Thenable {
    /// Method to run task and then running closures passed
    /// - Parameters:
    ///   - closure: closure which will be run when task succeed
    ///   - failClosure: closure which will be run when task fail
    ///   - deferClosure: closure which will be run after closure or failClosure
    /// - Returns: DropablePromise object
    @discardableResult
    func then(run closure: @escaping (Result) -> Void, whenFailed failClosure: @escaping (Result) -> Void, finally deferClosure: @escaping (Result) -> Void) -> DropablePromise {
        then(
            run: {
                closure($0)
                deferClosure($0)
            },
            whenFailed: {
                failClosure($0)
                deferClosure($0)
            }
        )
    }
    
    /// Method to execute request and then run any method passed
    /// - Parameters:
    ///   - observer: object that observe task
    ///   - method: observer method to call when task completed
    /// - Returns: DropablePromise object
    @discardableResult
    func then<Observer: AnyObject>(observing observer: Observer, call method: @escaping (Observer) -> ((Result) -> Void)) -> DropablePromise {
        return then { [weak observer] result in
            guard let observer = observer else { return }
            method(observer)(result)
        }
    }
    
    /// Method to execute request and then run any method passed
    /// - Parameters:
    ///   - observer: object that observe task
    ///   - method: observer method to call when succeed
    ///   - failMethod: observer method to call when fail
    /// - Returns: DropablePromise object
    @discardableResult
    func then<Observer: AnyObject>(observing observer: Observer, call method: @escaping (Observer) -> ((Result) -> Void), whenFailedCall failMethod: @escaping (Observer) -> ((Result) -> Void)) -> DropablePromise {
        return then(run: { [weak observer] result in
            guard let observer = observer else { return }
            method(observer)(result)
        }, whenFailed: { [weak observer] result in
            guard let observer = observer else { return }
            failMethod(observer)(result)
        })
    }
    
    /// Method to execute request and then run any method passed
    /// - Parameters:
    ///   - observer: object that observe task
    ///   - method: observer method to call when succeed
    ///   - failMethod: observer method to call when fail
    ///   - finalMethod: observer method to call when task completed
    /// - Returns: DropablePromise object
    @discardableResult
    func then<Observer: AnyObject>(observing observer: Observer, call method: @escaping (Observer) -> ((Result) -> Void), whenFailedCall failMethod: @escaping (Observer) -> ((Result) -> Void), finallyCall finalMethod: @escaping (Observer) -> ((Result) -> Void)) -> DropablePromise {
        return then(run: { [weak observer] result in
            guard let observer = observer else { return }
            method(observer)(result)
        }, whenFailed: { [weak observer] result in
            guard let observer = observer else { return }
            failMethod(observer)(result)
        }, finally: { [weak observer] result in
            guard let observer = observer else { return }
            finalMethod(observer)(result)
        })
    }
}
