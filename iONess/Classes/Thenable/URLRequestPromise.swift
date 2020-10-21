//
//  URLRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class URLRequestPromise<Response: URLResponse, Result: NetworkResult>: URLThenableRequest {
    public var urlValidator: URLValidator?
    public var dispatcher: DispatchQueue = .main
    
    @discardableResult
    open func then(run closure: @escaping (Result) -> Void) -> DropableURLRequest<Response> {
        fatalError("iONess Error: method did not overridden 'then(run closure: @escaping (URLResult) -> Void) -> DropableURLRequest<Response>'")
    }
}

open class ErrorRequestPromise<Response: URLResponse, Result: NetworkResult>: URLRequestPromise<Response, Result> {
    var error: Error
    
    init(error: Error) {
        self.error = error
    }
    
    @discardableResult
    open override func then(run closure: @escaping (Result) -> Void) -> DropableURLRequest<Response> {
        let error = self.error
        dispatcher.async {
            closure(.init(error: error))
        }
        return FailedURLRequest(error: error)
    }
    
}

open class HTTPRequestPromise<Response: URLResponse, Result: NetworkResult>: URLRequestPromise<Response, Result> {
    var urlRequest: URLRequest
    var urlSession: URLSession
    var retryControl: RetryControl?
    
    public init(request: HTTPRequestMessage, with session: URLSession, retryControl: RetryControl?) throws {
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
        self.urlSession = session
        self.retryControl = retryControl
    }
}
