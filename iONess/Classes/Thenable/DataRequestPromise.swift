//
//  DataRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Thenable HTTPRequest for get response data
open class DataRequestPromise<Response: URLResponse>: HTTPRequestPromise<Response, URLResult> {
    
    /// Default Init
    /// - Parameters:
    ///   - request: HTTPRequestMessage object which describe the request
    ///   - networkSessionManager: NetworkSessionManager
    ///   - retryControl: RetryControl object
    /// - Throws: Error when generating URLRequest from HTTPRequestMessage
    public override init(request: HTTPRequestMessage, with networkSessionManager: NetworkSessionManager, retryControl: RetryControl?) throws {
        try super.init(request: request, with: networkSessionManager, retryControl: retryControl)
    }
    
    /// Method to run closure after the request is finished.
    /// - Parameter closure: closure which will be run when the request is finished
    /// - Returns: DropableURLRequest<Response> object
    @discardableResult
    open override func then(run closure: @escaping (URLResult) -> Void) -> DropableURLRequest<Response> {
        let dispatcher = self.dispatcher
        return DropableDataRequest(
            networkSessionManager: networkSessionManager,
            request: urlRequest,
            retryControl: retryControl,
            urlValidator: urlValidator) { result in
            dispatcher.async {
                closure(result)
            }
        }
    }
}
