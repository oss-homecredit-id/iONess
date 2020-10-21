//
//  Thenable.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol Thenable {
    associatedtype Result
    associatedtype DropablePromise: Dropable
    
    @discardableResult
    func then(run closure: @escaping (Result) -> Void, whenFailed failClosure: @escaping (Result) -> Void) -> DropablePromise
    
    @discardableResult
    func then(run closure: @escaping (Result) -> Void) -> DropablePromise
}

