//
//  MappingThenable.swift
//  iONess
//
//  Created by Nayanda Haberty on 12/04/21.
//

import Foundation

public extension Thenable {
    /// Method to create new thenable that mapping the value of real thenable to new one
    /// - Parameter mapper: Mapper closure
    /// - Returns: MappingThenable
    func map<MappedResult>(_ mapper: @escaping (Result) -> MappedResult) -> MappingThenable<Self, MappedResult> {
        .init(self, mapper)
    }
}

/// Class that mapping result to other thenable
public class MappingThenable<MappedThenable: Thenable, MappedResult>: Thenable {
    public typealias Result = MappedResult
    public typealias DropablePromise = MappedThenable.DropablePromise
    public typealias Mapper = (MappedThenable.Result) -> MappedResult
    
    /// Thenable that its result mapped
    public let mappedThenable: MappedThenable
    
    let mapper: Mapper
    
    init(_ mappedThenable: MappedThenable, _ mapper: @escaping Mapper) {
        self.mappedThenable = mappedThenable
        self.mapper = mapper
    }
    
    /// Method to run task and then running closures passed
    /// - Parameters:
    ///   - closure: closure which will be run when task succeed
    ///   - failClosure: closure which will be run when task fail
    @discardableResult
    public func then(run closure: @escaping (MappedResult) -> Void, whenFailed failClosure: @escaping (MappedResult) -> Void) -> DropablePromise {
        let mapper = self.mapper
        return mappedThenable.then { result in
            closure(mapper(result))
        } whenFailed: { result in
            failClosure(mapper(result))
        }
    }
    
    /// Method to run task and then running closure passed
    /// - Parameter closure: closure which will be run when task finished
    @discardableResult
    public func then(run closure: @escaping (MappedResult) -> Void) -> DropablePromise {
        let mapper = self.mapper
        return mappedThenable.then { result in
            closure(mapper(result))
        }
    }
    
}
