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
}
