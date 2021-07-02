//
//  RequestMessage.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Message of the request
public protocol RequestMessage {
    /// url of the request message
    var url: URLCompatible { get }
    /// headers of the request message
    var headers: [String: String] { get }
    /// body of the request message
    var body: Data? { get }
}

public extension RequestMessage {
    /// True if message contains body
    var isHaveBody: Bool { body != nil }
}
