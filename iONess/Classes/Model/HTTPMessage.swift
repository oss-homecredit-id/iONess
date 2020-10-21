//
//  HTTPMessage.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol HTTPMessage {
    var url: URLCompatible { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

public extension HTTPMessage {
    var isHaveBody: Bool { body != nil }
}
