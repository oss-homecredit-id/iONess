//
//  ResponseDecoder.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Response Decoder
public protocol ResponseDecoder {
    associatedtype Decoded
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    func decode(from data: Data) throws -> Decoded
}

/// JSON Data response decoder into Decodable object
public struct JSONDecodableDecoder<DObject: Decodable>: ResponseDecoder {
    public typealias Decoded = DObject
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> DObject {
        try JSONDecoder().decode(DObject.self, from: data)
    }
}

/// Array JSON Data response decoder into Array of Decodable object
public struct ArrayJSONDecodableDecoder<DObject: Decodable>: ResponseDecoder {
    public typealias Decoded = Array<DObject>
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> Array<DObject> {
        try JSONDecoder().decode(Array<DObject>.self, from: data)
    }
}

/// JSON Data response decoder into Dictionary representation of JSON
public struct JSONResponseDecoder: ResponseDecoder {
    public typealias Decoded = [String: Any]
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> [String: Any] {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return json
    }
}

/// Array JSON Data response decoder into Array representation of JSON
public struct ArrayJSONResponseDecoder: ResponseDecoder {
    public typealias Decoded = Array<Any>
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> Array<Any> {
        guard let arrayJson = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return arrayJson
    }
}

/// Base class to Decode JSON Dictionary to object
open class BaseJSONDecoder<JSONType>: ResponseDecoder {
    public typealias Decoded = JSONType
    
    /// Default init
    required public init() { }
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> JSONType {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return try decode(from: json)
    }
    
    /// Perform decode data into given type
    /// - Parameter json: Dictionary representation of JSON
    /// - Throws: Decode error
    /// - Returns: object decoded
    open func decode(from json: [String: Any]) throws -> JSONType {
        throw NetworkSessionError(description: "iONess Error: JSON Decoder not implemented")
    }
}

/// Base class to Decode JSON String to object
open class BaseStringDecoder<ObjectType>: ResponseDecoder {
    public typealias Decoded = ObjectType
    
    /// String encoding of the data
    open var encoding: String.Encoding { .utf8 }
    
    /// Default init
    required public init() { }
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> ObjectType {
        guard let string = String(data: data, encoding: encoding) else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to String")
        }
        return try decode(from: string)
    }
    
    /// Perform decode data into given type
    /// - Parameter json: String representation of data
    /// - Throws: Decode error
    /// - Returns: object decoded
    open func decode(from json: String) throws -> ObjectType {
        throw NetworkSessionError(description: "iONess Error: JSON Decoder not implemented")
    }
}

/// Decoder to decode Array of JSON using another decoder to Decode each of Array content
public struct ArrayedJSONDecoder<JSONType>: ResponseDecoder {
    
    public typealias Decoded = Array<JSONType>
    
    var singleDecoder: BaseJSONDecoder<JSONType>
    
    /// Default initializer
    /// - Parameter singleDecoder: decoder to decode each Array content
    public init(singleDecoder: BaseJSONDecoder<JSONType>) {
        self.singleDecoder = singleDecoder
    }
    
    /// Perform decode data into given type
    /// - Parameter data: Data from request result
    /// - Throws: Decode error
    /// - Returns: object decoded
    public func decode(from data: Data) throws -> Array<JSONType> {
        guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [Any]")
        }
        return try jsonArray.compactMap { member in
            guard let json = member as? [String: Any] else {
                throw NetworkSessionError(description: "iONess Error: Failed to decode JSON String member to [String: Any]")
            }
            return try singleDecoder.decode(from: json)
        }
    }
}
