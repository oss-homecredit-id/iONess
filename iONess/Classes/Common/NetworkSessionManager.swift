//
//  NetworkManager.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public typealias Ness = NetworkSessionManager

open class NetworkSessionManager {
    public static var `default`: NetworkSessionManager = .init()
    
    public private(set) var session: URLSession
    public var duplicatedHandler: DuplicatedHandler
    let lock = NSLock()
    var completions: [NetworkRequest: URLCompletion<Any>] = [:]
    weak var delegate: NetworkSessionManagerDelegate?
    
    public init(
        with session: URLSession = .shared,
        onDuplicated handler: DefaultDuplicatedHandler = .keepAllCompletion) {
        self.session = session
        self.duplicatedHandler = handler
    }
    
    public init(
        with session: URLSession = .shared,
        duplicatedHandler: DuplicatedHandler) {
        self.session = session
        self.duplicatedHandler = duplicatedHandler
    }
    
    open func httpRequest(_ method: HTTPRequestMessage.Method = .get, withUrl url: URLCompatible) -> URLRequestBuilder {
        return .init(method: method, with: url, networkSessionManager: self)
    }
    
    public func dropAllRequest() {
        session.invalidateAndCancel()
    }
}

public typealias NessDelegate = NetworkSessionManagerDelegate

public protocol NetworkSessionManagerDelegate: class {
    func ness(_ manager: Ness, willRequest request: URLRequest) -> URLRequest
    func ness(_ manager: Ness, didRequest request: URLRequest) -> Void
}

public extension NetworkSessionManagerDelegate {
    func ness(_ manager: Ness, willRequest request: URLRequest) -> URLRequest { request }
    func ness(_ manager: Ness, didRequest request: URLRequest) -> Void { }
}
