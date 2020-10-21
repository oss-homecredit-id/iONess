//
//  HTTPResultMessage.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public struct HTTPResultMessage: HTTPMessage {
    public typealias Header = Dictionary<String, String>
    public let url: URLCompatible
    public let headers: Header
    public let body: Data?
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

extension HTTPResultMessage {
    
    public func parseBody(toStringEndcoded encoding: String.Encoding = .utf8) throws -> String {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        guard let result = String(data: data, encoding: encoding) else {
            throw NetworkSessionError(description: "iONess Error: failed to encode result to String")
        }
        return result
    }
    
    public func parseBody<Decoder: ResponseDecoder>(using decoder: Decoder) throws -> Decoder.Decoded {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try decoder.decode(from: data)
    }
    
    public func parseJSONBody() throws -> [String: Any] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [String: Any]")
        }
        return json
    }
    
    public func parseArrayJSONBody() throws -> [Any] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        guard let arrayJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw NetworkSessionError(description: "iONess Error: Failed to decode Data to [Any]")
        }
        return arrayJSON
    }
    
    public func parseJSONBody<DObject: Decodable>() throws -> DObject {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try JSONDecodableDecoder().decode(from: data)
    }
    
    public func parseArrayJSONBody<DObject: Decodable>() throws -> [DObject] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try ArrayJSONDecodableDecoder().decode(from: data)
    }
    
    public func parseJSONBody<DOBject: Decodable>(forType type: DOBject.Type) throws -> DOBject {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try JSONDecodableDecoder().decode(from: data)
    }
    
    public func parseArrayJSONBody<DObject: Decodable>(forType type: DObject.Type) throws -> [DObject] {
        guard let data = body else {
            throw NetworkSessionError(description: "iONess Error: no result to decode")
        }
        return try ArrayJSONDecodableDecoder().decode(from: data)
    }
}
