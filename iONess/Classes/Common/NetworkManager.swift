//
//  NetworkManager.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public typealias Ness = NetworkManager

open class NetworkManager {
    public static var `default`: NetworkManager = .init()
    
    var networkSessionManager: NetworkSessionManager
    
    public init(
        with session: URLSession = .shared,
        onDuplicated handler: DefaultDuplicatedHandler = .keepAllCompletion) {
        networkSessionManager = .init(with: session, duplicatedHandler: handler)
    }
    
    public init(
        with session: URLSession = .shared,
        duplicatedHandler: DuplicatedHandler) {
        networkSessionManager = .init(with: session, duplicatedHandler: duplicatedHandler)
    }
    
    open func httpRequest(_ method: HTTPRequestMessage.Method = .get, withUrl url: URLCompatible) -> URLRequestBuilder {
        return .init(method: method, with: url, networkSessionManager: networkSessionManager)
    }
}
