//
//  ResponseDecoder.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol ResponseDecoder {
    associatedtype Decoded
    func decode(from data: Data) throws -> Decoded
}

public struct JSONDecodableDecoder<DObject: Decodable>: ResponseDecoder {
    public typealias Decoded = DObject
    
    public func decode(from data: Data) throws -> DObject {
        try JSONDecoder().decode(DObject.self, from: data)
    }
}

public struct ArrayJSONDecodableDecoder<DObject: Decodable>: ResponseDecoder {
    public typealias Decoded = Array<DObject>
    
    public func decode(from data: Data) throws -> Array<DObject> {
        try JSONDecoder().decode(Array<DObject>.self, from: data)
    }
}

public struct JSONResponseDecoder: ResponseDecoder {
    public typealias Decoded = [String: Any]
    
    public func decode(from data: Data) throws -> [String: Any] {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return json
    }
}

public struct ArrayJSONResponseDecoder: ResponseDecoder {
    public typealias Decoded = Array<Any>
    
    public func decode(from data: Data) throws -> Array<Any> {
        guard let arrayJson = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return arrayJson
    }
}

open class BaseJSONDecoder<JSONType>: ResponseDecoder {
    public typealias Decoded = JSONType
    
    required public init() { }
    
    public func decode(from data: Data) throws -> JSONType {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return try decode(from: json)
    }
    
    open func decode(from json: [String: Any]) throws -> JSONType {
        throw NetworkSessionError(description: "iONess Error: JSON Decoder not implemented")
    }
}

open class BaseStringDecoder<ObjectType>: ResponseDecoder {
    public typealias Decoded = ObjectType
    
    open var encoding: String.Encoding { .utf8 }
    
    required public init() { }
    
    public func decode(from data: Data) throws -> ObjectType {
        guard let string = String(data: data, encoding: encoding) else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to String")
        }
        return try decode(from: string)
    }
    
    open func decode(from json: String) throws -> ObjectType {
        throw NetworkSessionError(description: "iONess Error: JSON Decoder not implemented")
    }
}

public struct ArrayedJSONDecoder<JSONType>: ResponseDecoder {
    public typealias Decoded = Array<JSONType>
    
    var singleDecoder: BaseJSONDecoder<JSONType>
    
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
