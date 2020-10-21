//
//  HTTPRequestMessage.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public class HTTPRequestMessage: HTTPMessage {
    public typealias Header = Dictionary<String, String>
    public typealias URLParameters = Dictionary<String, String>
    public var url: URLCompatible = ""
    public var headers: Header = [:]
    public var method: Method = .get
    public var urlParameters: Header = [:]
    public var encoder: HTTPBodyEncoder? {
        willSet {
            encoder?.relatedHeaders?.forEach { key, _ in
                headers.removeValue(forKey: key)
            }
        }
        didSet {
            encoder?.relatedHeaders?.forEach {
                headers[$0] = $1
            }
        }
    }
    public var encodedBody: Any? {
        didSet {
            _body = nil
        }
    }
    private var _body: Data?
    public var body: Data? {
        get {
            if _body == nil && encodedBody != nil {
                _body = try? getDataBody()
            }
            return _body
        }
        set {
            _body = newValue
        }
    }
    public func getFullUrl() throws -> URL {
        try url.asUrl(with: urlParameters)
    }
    
    public func getDataBody() throws -> Data {
        guard let body = encodedBody else {
            throw NetworkSessionError(originalError: nil, statusCode: -1, description: "iONess Error: No HTTPBody")
        }
        guard let encoder = encoder else {
            guard let data = body as? Data ?? (body as? String)?.data(using: .utf8) else {
                throw NetworkSessionError(description: "iONess Error: No encoder for the body")
            }
            return data
        }
        return try encoder.encode(body)
    }
    
    public enum Method {
        case post
        case get
        case put
        case patch
        case delete
        case head
        case connect
        case options
        case trace
        case none
        case custom(String)
        
        var asString: String {
            switch self {
            case .post:
                return "POST"
            case .get:
                return "GET"
            case .put:
                return "PUT"
            case .patch:
                return "PATCH"
            case .delete:
                return "DELETE"
            case .head:
                return "HEAD"
            case .connect:
                return "CONNECT"
            case .options:
                return "OPTIONS"
            case .trace:
                return "TRACE"
            case .custom(let string):
                return string
            default:
                return ""
            }
        }
    }
}
