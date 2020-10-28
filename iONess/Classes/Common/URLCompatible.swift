//
//  URLCompatible.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol URLCompatible {
    func asUrl() throws -> URL
    func asUrl(with parameters: HTTPRequestMessage.URLParameters) throws -> URL
}

extension String: URLCompatible {
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
    
    public func asUrl() throws -> URL {
        guard let url = URL(string: self) else {
            throw NetworkSessionError(description: "iONess Error: invalid url \"\(self)\"")
        }
        return url
    }
}

extension URL: URLCompatible {
    public func asUrl(with parameters: HTTPRequestMessage.URLParameters) throws -> URL {
        try absoluteString.asUrl(with: parameters)
    }
    
    public func asUrl() throws -> URL {
        return self
    }
}

public extension URL {
    func asMutableRequest() -> NSMutableURLRequest {
        NSMutableURLRequest(url: self)
    }
}
