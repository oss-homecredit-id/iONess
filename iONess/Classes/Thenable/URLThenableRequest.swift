//
//  URLThenableRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol URLThenableRequest: Thenable where DropablePromise: DropableURLRequest<Response>, Result: NetworkResult {
    associatedtype Response: URLResponse
    var urlValidator: URLValidator? { get set }
    var dispatcher: DispatchQueue { get set }
    @discardableResult
    func executeAndForget() -> DropableURLRequest<Response>
}

public extension URLThenableRequest {
    
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
    
    @discardableResult
    func executeAndForget() -> DropableURLRequest<Response> {
        then { _ in }
    }
}

public extension URLThenableRequest {
    
    @discardableResult
    func completionDispatch(on dispatcher: DispatchQueue) -> Self {
        var requestWithDispatch = self
        requestWithDispatch.dispatcher = dispatcher
        return requestWithDispatch
    }
    
    @discardableResult
    func validate(statusCode: Int) -> Self {
        return validate(statusCodes: statusCode..<statusCode + 1)
    }
    
    @discardableResult
    func validate(statusCodes: Range<Int>) -> Self {
        validate(using: StatusCodeValidator(statusCodes))
    }
    
    @discardableResult
    func validate(shouldHaveHeaders headers: [String:String]) -> Self {
        validate(using: HeaderValidator(headers))
    }
    
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
    func aggregate(with request: Self) -> RequestAggregator<Self> {
        RequestAggregator(requests: [self, request])
    }
}
