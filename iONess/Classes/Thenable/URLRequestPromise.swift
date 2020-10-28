//
//  URLRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Base class for Thenable URLRequest
open class URLRequestPromise<Response: URLResponse, Result: NetworkResult>: URLThenableRequest {
    /// URLValidator which will validate result from URL Request
    public var urlValidator: URLValidator?
    /// DispatchQueue which will run the completion closure
    public var dispatcher: DispatchQueue = .main
    
    /// Default init
    public init() { }
    
    /// Method to run closure after the request is finished. It should be overriden, otherwise it will throw fatalError
    /// - Parameter closure: closure which will be run when the request is finished
    /// - Returns: DropableURLRequest<Response> object
    @discardableResult
    open func then(run closure: @escaping (Result) -> Void) -> DropableURLRequest<Response> {
        fatalError("iONess Error: method did not overridden 'then(run closure: @escaping (URLResult) -> Void) -> DropableURLRequest<Response>'")
    }
}

/// Thenable URLRequest which should be used as Thenable for URLRequest which already failed when prepared
open class ErrorRequestPromise<Response: URLResponse, Result: NetworkResult>: URLRequestPromise<Response, Result> {
    var error: Error
    
    /// Default Init
    /// - Parameter error: Error on prepared
    public init(error: Error) {
        self.error = error
    }
    
    /// Method to run closure after the request is finished. It should automatically fail
    /// - Parameter closure: Closure which will fail
    /// - Returns: FailedURLRequest object
    @discardableResult
    open override func then(run closure: @escaping (Result) -> Void) -> DropableURLRequest<Response> {
        let error = self.error
        dispatcher.async {
            closure(.init(error: error))
        }
        return FailedURLRequest(error: error)
    }
    
}

/// Thenable HTTPRequest
open class HTTPRequestPromise<Response: URLResponse, Result: NetworkResult>: URLRequestPromise<Response, Result> {
    var urlRequest: URLRequest
    var networkSessionManager: NetworkSessionManager
    var retryControl: RetryControl?
    
    /// Default Init
    /// - Parameters:
    ///   - request: HTTPRequestMessage object which describe the request
    ///   - networkSessionManager: NetworkSessionManager
    ///   - retryControl: RetryControl object
    /// - Throws: Error when generating URLRequest from HTTPRequestMessage
    public init(request: HTTPRequestMessage, with networkSessionManager: NetworkSessionManager, retryControl: RetryControl?) throws {
        let mutableRequest = try request.getFullUrl().asMutableRequest()
        for header in request.headers {
            mutableRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        if request.isHaveBody {
            let dataBody = try request.getDataBody()
            mutableRequest.httpBody = dataBody
        }
        let method = request.method.asString
        if !method.isEmpty {
            mutableRequest.httpMethod = method
        }
        self.urlRequest = mutableRequest as URLRequest
        self.networkSessionManager = networkSessionManager
        self.retryControl = retryControl
    }
}
