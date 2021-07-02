//
//  RequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty on 02/07/21.
//

import Foundation
import Ergo

/// Request Promise protocol
public protocol RequestPromise: Thenable {
    associatedtype Handler: RequestHandler
    /// status of request
    var status: RequestStatus { get }
    /// handler of request
    var handler: Handler? { get }
}

public extension RequestPromise {
    /// handler of request
    var status: RequestStatus {
        handler?.status ?? .error(NessError(description: "iONess Error: Failed to create request handler"))
    }
}

/// Base Request Promise class
open class URLRequestPromise<Handler: RequestHandler>: ClosurePromise<Handler.Result>, RequestPromise {
    
    /// handler of request
    public let handler: Handler?
    
    /// Default initializer, it will automatically run a request unless handler is null, then it will automatically emit error
    /// - Parameter requestHandler: handler of request
    public init(requestHandler: Handler?) {
        self.handler = requestHandler
        guard let handler = requestHandler else {
            super.init(currentQueue: .current) { done in
                done(nil, NessError(description: "iONess Error: Failed to create request handler"))
            }
            return
        }
        super.init(currentQueue: .main) { done in
            handler.doRequest { result in
                done(result, result.error)
            }
        }
    }
    
    /// Drop request
    /// - Parameter error: cause of drop
    open override func drop(becauseOf error: Error) {
        super.drop(becauseOf: error)
        handler?.drop(becauseOf: error)
    }
}

/// Data Promise
open class DataPromise: URLRequestPromise<DataRequestHandler> {
    
    /// Default initializer, it will automatically run a request unless its failed to create handler, then it will automatically emit error
    /// - Parameters:
    ///   - request: request object
    ///   - networkSessionManager: network manager
    ///   - retryControl: retry control
    ///   - validator: request validator
    public init(request: HTTPRequestMessage,
                with networkSessionManager: NetworkSessionManager,
                retryControl: RetryControl?,
                validator: ResponseValidator?) {
        do {
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
            super.init(
                requestHandler: DataRequestHandler(
                    networkSessionManager: networkSessionManager,
                    request: mutableRequest as URLRequest,
                    responseValidator: validator,
                    retryControl: retryControl
                )
            )
        } catch {
            super.init(requestHandler: nil)
        }
    }
    
    /// Drop request
    /// - Parameter error: cause of drop
    open override func drop(becauseOf error: Error) {
        super.drop(becauseOf: error)
    }
}

/// Upload promise
open class UploadPromise: URLRequestPromise<UploadRequestHandler> {
    
    /// Default initializer, it will automatically run a request unless its failed to create handler, then it will automatically emit error
    /// - Parameters:
    ///   - request: request object
    ///   - fileUrl: location of file for upload
    ///   - networkSessionManager: network manager
    ///   - retryControl: retry control
    ///   - validator: request validator
    public init(request: HTTPRequestMessage,
                fileUrl: URL,
                with networkSessionManager: NetworkSessionManager,
                retryControl: RetryControl?,
                validator: ResponseValidator?) {
        do {
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
            super.init(
                requestHandler: UploadRequestHandler(
                    networkSessionManager: networkSessionManager,
                    request: mutableRequest as URLRequest,
                    fileUrl: fileUrl,
                    responseValidator: validator,
                    retryControl: retryControl
                )
            )
        } catch {
            super.init(requestHandler: nil)
        }
    }
    
    /// Drop request
    /// - Parameter error: cause of drop
    open override func drop(becauseOf error: Error) {
        super.drop(becauseOf: error)
    }
}

/// Download Promise
open class DownloadPromise: URLRequestPromise<DownloadRequestHandler>, Resumable {
    
    /// Default initializer, it will automatically run a request unless its failed to create handler, then it will automatically emit error
    /// - Parameters:
    ///   - request: request object
    ///   - targetUrl: location of file when download finished
    ///   - networkSessionManager: network manager
    ///   - retryControl: retry control
    ///   - validator: request validator
    public init(request: HTTPRequestMessage,
                targetUrl: URL,
                with networkSessionManager: NetworkSessionManager,
                retryControl: RetryControl?,
                validator: ResponseValidator?) {
        do {
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
            super.init(
                requestHandler: DownloadRequestHandler(
                    networkSessionManager: networkSessionManager,
                    request: mutableRequest as URLRequest,
                    targetUrl: targetUrl,
                    responseValidator: validator,
                    retryControl: retryControl
                )
            )
        } catch {
            super.init(requestHandler: nil)
        }
    }
    
    /// Drop request
    /// - Parameter error: cause of drop
    open override func drop(becauseOf error: Error) {
        super.drop(becauseOf: error)
    }
}
