//
//  HTTPBodyEncoder.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol HTTPBodyEncoder {
    var relatedHeaders: [String: String]? { get }
    func encode(_ any: Any) throws -> Data
}

public extension HTTPBodyEncoder {
    var relatedHeaders: [String: String]? { nil }
}

public class StringBodyEncoder: HTTPBodyEncoder {
    let encoding: String.Encoding
    
    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }
    
    public func encode(_ any: Any) throws -> Data {
        guard let string = any as? String else {
            throw NetworkSessionError(description: "iONess Error: body is not String")
        }
        guard let data = string.data(using: encoding) else {
            throw NetworkSessionError(description: "iONess Error: failed to encode string to data using \(encoding) encoding")
        }
        return data
    }
}

public class JSONEncodableBodyEncoder<EObject: Encodable>: HTTPBodyEncoder {
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    public init(forType type: EObject.Type) { }
    
    public func encode(_ any: Any) throws -> Data {
        guard let encodable = any as? EObject else {
            throw NetworkSessionError(description: "iONess Error: body is not Encodable")
        }
        return try JSONEncoder().encode(encodable)
    }
}

public class JSONArrayEncodableBodyEncoder<EObject: Encodable>: HTTPBodyEncoder {
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    public init(forType type: EObject.Type) { }
    
    public func encode(_ any: Any) throws -> Data {
        guard let encodable = any as? [EObject] else {
            throw NetworkSessionError(description: "iONess Error: body is not Encodable")
        }
        return try JSONEncoder().encode(encodable)
    }
}

public class JSONBodyEncoder: HTTPBodyEncoder {
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    public func encode(_ any: Any) throws -> Data {
        guard let json = any as? [String: Any] else {
            throw NetworkSessionError(description: "iONess Error: body is not Dictionary")
        }
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}

public class JSONArrayBodyEncoder: HTTPBodyEncoder {
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    public func encode(_ any: Any) throws -> Data {
        guard let jsonArray = any as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: body is not Dictionary")
        }
        return try JSONSerialization.data(withJSONObject: jsonArray, options: [])
    }
}
