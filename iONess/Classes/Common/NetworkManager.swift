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
    
    var session: URLSession
    
    public init(with session: URLSession = .shared) {
        self.session = session
    }
    
    open func httpRequest(_ method: HTTPRequestMessage.Method = .get, withUrl url: URLCompatible) -> URLRequestBuilder {
        return .init(method: method, with: url, session: session)
    }
}
