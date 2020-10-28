//
//  URLThenableRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Thenable URL Request protocol
public protocol URLThenableRequest: Thenable where DropablePromise: DropableURLRequest<Response>, Result: NetworkResult {
    associatedtype Response: URLResponse
    /// URLValidator which will validate result from URL Request
    var urlValidator: URLValidator? { get set }
    /// DispatchQueue which will run the completion closure
    var dispatcher: DispatchQueue { get set }
    /// Method to execute and ignore any result
    @discardableResult
    func executeAndForget() -> DropableURLRequest<Response>
}

public extension URLThenableRequest {
    
    /// Method to execute request and then run any closure passed
    /// - Parameters:
    ///   - closure: Closure which will run when request succeed
    ///   - failClosure: Closure which will run when request fail
    /// - Returns: DroppableURLRequest object
    @discardableResult
    func then(run closure: @escaping (Result) -> Void, whenFailed failClosure: @escaping (Result) -> Void) -> DropableURLRequest<Response> {
        return then { result in
            if result.error != nil {
                failClosure(result)
                return
            }
            closure(result)
        }
    }
    
    /// Method to execute and ignore any result
    /// - Returns: DroppableURLRequest object
    @discardableResult
    func executeAndForget() -> DropableURLRequest<Response> {
        then { _ in }
    }
}

public extension URLThenableRequest {
    
    /// Method to set DispatchQueue where the completion will run
    /// - Parameter dispatcher: DispatchQueue object
    /// - Returns: URLThenableRequest which have custom DispatchQueue
    @discardableResult
    func completionDispatch(on dispatcher: DispatchQueue) -> Self {
        var requestWithDispatch = self
        requestWithDispatch.dispatcher = dispatcher
        return requestWithDispatch
    }
    
    /// Method to add URLValidator which validate using status code
    /// - Parameter statusCode: valid status code
    /// - Returns: URLThenableRequest which have status code URLValidator combined with previous validator if have any
    @discardableResult
    func validate(statusCode: Int) -> Self {
        return validate(statusCodes: statusCode..<statusCode + 1)
    }
    
    /// Method to add URLValidator which validate using status codes
    /// - Parameter statusCodes: valid status codes
    /// - Returns: URLThenableRequest which have status codes URLValidator combined with previous validator if have any
    @discardableResult
    func validate(statusCodes: Range<Int>) -> Self {
        validate(using: StatusCodeValidator(statusCodes))
    }
    
    /// Method to add URLValidator which validate result headers
    /// - Parameter headers: valid result headers
    /// - Returns: URLThenableRequest which have headers URLValidator combined with previous validator if have any
    @discardableResult
    func validate(shouldHaveHeaders headers: [String:String]) -> Self {
        validate(using: HeaderValidator(headers))
    }
    
    /// Method to add custom URLValidator
    /// - Parameter validator: custom URLValidator
    /// - Returns: URLThenableRequest which have custom URLValidator combined with previous validator if have any
    @discardableResult
    func validate(using validator: URLValidator) -> Self {
        var requestWithValidation = self
        guard let current = urlValidator else {
            requestWithValidation.urlValidator = validator
            return self
        }
        requestWithValidation.urlValidator = current.combine(with: validator)
        return self
    }
}

public extension URLThenableRequest {
    /// Method to aggregate request with another request
    /// - Parameter request: other request to aggregate
    /// - Returns: RequestAggregator object
    func aggregate(with request: Self) -> RequestAggregator<Self> {
        RequestAggregator(requests: [self, request])
    }
}
