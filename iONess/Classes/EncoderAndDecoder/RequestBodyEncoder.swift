//
//  RequestBodyEncoder.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Encoder for HTTP Body
public protocol RequestBodyEncoder {
    /// header to be added on the request related to body
    var relatedHeaders: [String: String]? { get }
    /// Encode any type to data for http body
    /// - Parameter any: any type of data
    func encode(_ any: Any) throws -> Data
}

public extension RequestBodyEncoder {
    var relatedHeaders: [String: String]? { nil }
}

/// RequestBodyEncoder for String
public final class StringBodyEncoder: RequestBodyEncoder {
    let encoding: String.Encoding
    
    /// Default init
    /// - Parameter encoding: type of String encoding
    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }
    
    /// Encode String into data
    /// - Parameter any: String, it will throw error if type is not String
    /// - Throws: NetworkSessionError
    /// - Returns: Converted String to Data
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

/// RequestBodyEncoder for Encodable object to JSON
public final class JSONEncodableBodyEncoder<EObject: Encodable>: RequestBodyEncoder {
    /// Default header for JSON  Content-Type
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    /// Default init
    /// - Parameter type: Type of object
    public init(forType type: EObject.Type) { }
    
    /// Encode object match the type into JSON data
    /// - Parameter any: Object match with typa passed in initializer, it will throw error if type did not match
    /// - Throws: NetworkSessionError
    /// - Returns: Converted object to JSON Data
    public func encode(_ any: Any) throws -> Data {
        guard let encodable = any as? EObject else {
            throw NetworkSessionError(description: "iONess Error: body is not Encodable")
        }
        return try JSONEncoder().encode(encodable)
    }
}

/// RequestBodyEncoder for array of Encodable object to JSON
public final class JSONArrayEncodableBodyEncoder<EObject: Encodable>: RequestBodyEncoder {
    /// Default header for JSON  Content-Type
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    /// Default init
    /// - Parameter type: Type of object
    public init(forType type: EObject.Type) { }
    
    /// Encode array of object match the type into JSON data
    /// - Parameter any: array  of Object match with typa passed in initializer, it will throw error if type did not match
    /// - Throws: NetworkSessionError
    /// - Returns: Converted object to JSON Data
    public func encode(_ any: Any) throws -> Data {
        guard let encodable = any as? [EObject] else {
            throw NetworkSessionError(description: "iONess Error: body is not Encodable")
        }
        return try JSONEncoder().encode(encodable)
    }
}

/// RequestBodyEncoder to decode Dictionary of String and Any to JSON
public final class JSONBodyEncoder: RequestBodyEncoder {
    /// Default header for JSON  Content-Type
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    /// Default init
    public init() { }
    
    /// Encode Dictionary into JSON data
    /// - Parameter any: Dictionary of String and Any, it will throw error if type did not match
    /// - Throws: NetworkSessionError
    /// - Returns: Converted Dictionary to JSON Data
    public func encode(_ any: Any) throws -> Data {
        guard let json = any as? [String: Any] else {
            throw NetworkSessionError(description: "iONess Error: body is not Dictionary")
        }
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}

/// RequestBodyEncoder to decode Array of Any to JSON
public final class JSONArrayBodyEncoder: RequestBodyEncoder {
    /// Default header for JSON  Content-Type
    public var relatedHeaders: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    /// Default init
    public init() { }
    
    /// Encode Array into JSON data
    /// - Parameter any: Array of Any,  it will throw error if type did not match
    /// - Throws: NetworkSessionError
    /// - Returns: Converted Array to JSON Data
    public func encode(_ any: Any) throws -> Data {
        guard let jsonArray = any as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: body is not Dictionary")
        }
        return try JSONSerialization.data(withJSONObject: jsonArray, options: [])
    }
}
