//
//  DropableURLRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class DropableURLRequest<Response: URLResponse>: Dropable {
    open var status: DropableStatus<Response> { .idle }
    public init() { }
    open func drop() { }
}

open class BaseDropableURLRequest<Response: URLResponse, Result>: DropableURLRequest<Response> {
    let urlValidator: URLValidator?
    let retryControl: RetryControl?
    let networkSessionManager: NetworkSessionManager
    let request: URLRequest
    let completion: (Result) -> Void
    
    open override var status: DropableStatus<Response> {
        fatalError("iONess Error: method did not overridden 'status { get }'")
    }
    open override func drop() {
        fatalError("iONess Error: method did not overridden 'drop()'")
    }
    
    public init(
        networkSessionManager: NetworkSessionManager,
        request: URLRequest,
        urlValidator: URLValidator?,
        retryControl: RetryControl?,
        completion: @escaping (Result) -> Void) {
        self.networkSessionManager = networkSessionManager
        self.request = request
        self.urlValidator = urlValidator
        self.retryControl = retryControl
        self.completion = completion
    }
}

extension BaseDropableURLRequest {
    
    static func validate(response: URLResponse?, with validator: URLValidator?) -> Error? {
        guard let response = response else {
            return NetworkSessionError(description: "iONess Error: get no response from server")
        }
        let validation = validator?.validate(for: response) ?? .valid
        switch validation {
        case .invalidWithReason(let reason):
            return NetworkSessionError(description: reason)
        case .invalid:
            return NetworkSessionError(description: "iONess Error: response invalid for unknown reason")
        default:
            return nil
        }
    }
    
    static func retryIfShould(
        with retryControl: RetryControl?,
        error: Error,
        request: URLRequest,
        _ response: URLResponse?,
        _ onRetry: @escaping () -> Void,
        onNoRetry: @escaping () -> Void) -> Void {
        guard !error.causeByCancel,
              let retryControl = retryControl else {
            onNoRetry()
            return
        }
        retryControl.shouldRetry(
            for: request,
            response: response,
            error: error
        ) { retryStatus in
            switch retryStatus {
            case .retryAfter(let delay):
                let dispatcher: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main
                dispatcher.asyncAfter(deadline: .now() + delay, execute: onRetry)
            case .retry:
                onRetry()
            case .noRetry:
                onNoRetry()
            }
        }
    }
}

public class FailedURLRequest<Response: URLResponse>: DropableURLRequest<Response> {
    let error: Error
    init(error: Error) {
        self.error = error
    }
    
    public override var status: DropableStatus<Response> {
        .error(error)
    }
}

