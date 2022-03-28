//
//  NetworkManager.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public typealias Ness = NetworkSessionManager

/// Network Session Manager
open class NetworkSessionManager {
    /// default Network Session Manager
    public static var `default`: NetworkSessionManager = .init()
    
    /// managed session
    public private(set) var session: URLSession
    /// NetworkSessionManagerDelegate
    public weak var delegate: NetworkSessionManagerDelegate?
    /// handler of duplicated request in managed session
    public var duplicatedHandler: DuplicatedHandler
    /// timeout request interval
    public var timeout: TimeInterval = 30 {
        didSet {
            session.configuration.timeoutIntervalForRequest = timeout
            session.configuration.timeoutIntervalForResource = timeout
        }
    }
    
    let lock = NSLock()
    var completions: [NetworkRequest: URLCompletion<Any>] = [:]
    
    /// Initializer
    /// - Parameters:
    ///   - session: URLSession to manage
    ///   - handler: default duplicated handler, default is keep all completion
    public init(
        with session: URLSession = .shared,
        onDuplicated handler: DefaultDuplicatedHandler = .keepAllCompletion) {
        self.timeout = max(
            session.configuration.timeoutIntervalForResource,
            session.configuration.timeoutIntervalForResource
        )
        self.session = session
        self.duplicatedHandler = handler
    }
    
    /// Initializer
    /// - Parameters:
    ///   - session: URLSession to manage
    ///   - duplicatedHandler: handler of duplicated request in managed session
    public init(
        with session: URLSession = .shared,
        duplicatedHandler: DuplicatedHandler) {
        self.timeout = max(
            session.configuration.timeoutIntervalForResource,
            session.configuration.timeoutIntervalForResource
        )
        self.session = session
        self.duplicatedHandler = duplicatedHandler
    }
    
    /// Perform http request build
    /// - Parameters:
    ///   - method: HTTP method, the default is get
    ///   - url: url of request
    /// - Returns: RequestBuilder
    open func httpRequest(_ method: HTTPRequestMessage.Method = .get, withUrl url: URLCompatible) -> RequestBuilder {
        return .init(method: method, with: url, networkSessionManager: self)
    }
    
    /// drop all running request
    public func dropAllRequest() {
        session.invalidateAndCancel()
    }
}

public typealias NessDelegate = NetworkSessionManagerDelegate

/// NetworkSessionManagerDelegate
public protocol NetworkSessionManagerDelegate: AnyObject {
    /// Perform manipulation before each request
    /// - Parameters:
    ///   - manager: NetworkSessionManager
    ///   - request: request that will execute
    func ness(_ manager: Ness, willRequest request: URLRequest) -> URLRequest
    /// Notified after each request
    /// - Parameters:
    ///   - manager: NetworkSessionManager
    ///   - request: executed request
    func ness(_ manager: Ness, didRequest request: URLRequest) -> Void
}

public extension NetworkSessionManagerDelegate {
    func ness(_ manager: Ness, willRequest request: URLRequest) -> URLRequest { request }
    func ness(_ manager: Ness, didRequest request: URLRequest) -> Void { }
}
