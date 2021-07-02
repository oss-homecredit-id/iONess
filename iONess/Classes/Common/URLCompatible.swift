//
//  URLCompatible.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Protocol to make project can be treated as URL
public protocol URLCompatible {
    /// Convert object to URL
    func asUrl() throws -> URL
    /// Convert object to URL with given parameters
    /// - Parameter parameters: URL Parameters
    func asUrl(with parameters: HTTPRequestMessage.URLParameters) throws -> URL
}

extension String: URLCompatible {
    /// Convert object to URL with given parameters
    /// - Parameter parameters: URL Parameters
    /// - Throws: NetworkSessionError
    /// - Returns: URL object
    public func asUrl(with parameters: HTTPRequestMessage.URLParameters) throws -> URL {
        var constructedURL: String = ""
        for parameter in parameters {
            guard let key: String = parameter.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let value = parameter.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                continue
            }
            constructedURL = "\(constructedURL)\(key)=\(value)&"
        }
        if !constructedURL.isEmpty {
            constructedURL = String(constructedURL.dropLast())
        }
        guard let url = URL(string: "\(self)\(constructedURL)") else {
            throw NetworkSessionError(description: "iONess Error: invalid url \"\(self)\"")
        }
        return url
    }
    
    /// Convert object to URL with given parameters
    /// - Throws: NetworkSessionError
    /// - Returns: URL object
    public func asUrl() throws -> URL {
        guard let url = URL(string: self) else {
            throw NetworkSessionError(description: "iONess Error: invalid url \"\(self)\"")
        }
        return url
    }
}

extension URL: URLCompatible {
    /// Convert object to URL with given parameters
    /// - Parameter parameters: URL Parameters
    /// - Throws: NetworkSessionError
    /// - Returns: URL object
    public func asUrl(with parameters: HTTPRequestMessage.URLParameters) throws -> URL {
        try absoluteString.asUrl(with: parameters)
    }
    
    /// Convert object to URL with given parameters
    /// - Throws: NetworkSessionError
    /// - Returns: URL object
    public func asUrl() throws -> URL {
        return self
    }
}

public extension URL {
    /// Convert URL into mutable Request
    /// - Returns: NSMutableURLRequest
    func asMutableRequest() -> NSMutableURLRequest {
        NSMutableURLRequest(url: self)
    }
}
