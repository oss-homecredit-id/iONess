//
//  HTTPResponseMessage.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// HTTP Response Message
public struct HTTPResponseMessage: RequestMessage {
    public typealias Header = Dictionary<String, String>
    /// URL of response
    public let url: URLCompatible
    /// headers of response
    public let headers: Header
    /// body of response
    public let body: Data?
    /// status code of response
    public let statusCode: Int
    
    init(httpResponse: HTTPURLResponse, body: Data? = nil) {
        var headers: HTTPRequestMessage.Header = [:]
        for member in httpResponse.allHeaderFields {
            guard let key = member.key as? String,
                  let value = member.value as? String else { continue }
            headers[key] = value
        }
        self.headers = headers
        self.body = body
        self.url = httpResponse.url ?? ""
        self.statusCode = httpResponse.statusCode
    }
}

public extension HTTPResponseMessage {
    
    /// Parse body into string
    /// - Parameter encoding: String encoding
    /// - Throws: Error when fail to parse
    /// - Returns: String encoded
    func parseBody(toStringEndcoded encoding: String.Encoding = .utf8) throws -> String {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        guard let result = String(data: data, encoding: encoding) else {
            throw NetworkSessionError(description: "iONess Error: failed to encode result to String")
        }
        return result
    }
    
    /// Parse body using decoder
    /// - Parameter decoder: Decoder
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded body
    func parseBody<Decoder: ResponseDecoder>(using decoder: Decoder) throws -> Decoder.Decoded {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try decoder.decode(from: data)
    }
    
    /// Parse body into Dictionary representation of JSON
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded JSON
    func parseJSONBody() throws -> [String: Any] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return json
    }
    
    /// Parse body into Array representation of JSON
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded JSON
    func parseArrayJSONBody() throws -> [Any] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        guard let arrayJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [Any]")
        }
        return arrayJSON
    }
    
    /// Parse JSON body into decodable object
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded JSON
    func parseJSONBody<DObject: Decodable>() throws -> DObject {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try JSONDecodableDecoder().decode(from: data)
    }
    
    /// Parse Array JSON body into array of decodable object
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded JSON
    func parseArrayJSONBody<DObject: Decodable>() throws -> [DObject] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try ArrayJSONDecodableDecoder().decode(from: data)
    }
    
    /// Parse JSON body into decodable object
    /// - Parameter type: type of decodable object
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded JSON
    func parseJSONBody<DOBject: Decodable>(forType type: DOBject.Type) throws -> DOBject {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try JSONDecodableDecoder().decode(from: data)
    }
    
    /// Parse JSON body into array of decodable object
    /// - Parameter type: type of decodable object
    /// - Throws: Error when fail to parse
    /// - Returns: Decoded JSON
    func parseArrayJSONBody<DObject: Decodable>(forType type: DObject.Type) throws -> [DObject] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try ArrayJSONDecodableDecoder().decode(from: data)
    }
}
