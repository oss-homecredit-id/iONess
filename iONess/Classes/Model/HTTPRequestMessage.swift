//
//  HTTPRequestMessage.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// HTTP Request Message
public final class HTTPRequestMessage: RequestMessage {
    public typealias Header = Dictionary<String, String>
    public typealias URLParameters = Dictionary<String, String>
    /// URL of the request
    public var url: URLCompatible = ""
    /// headers of the request
    public var headers: Header = [:]
    /// method of the request
    public var method: Method = .get
    /// parameters of the request
    public var urlParameters: Header = [:]
    /// current request body encoder
    public var encoder: RequestBodyEncoder? {
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
    /// encoded body
    public var encodedBody: Any? {
        didSet {
            _body = nil
        }
    }
    private var _body: Data?
    /// data representation of body
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
    /// URL + URL Parameters
    /// - Throws: Error when failed to build a URL
    /// - Returns: URL
    public func getFullUrl() throws -> URL {
        try url.asUrl(with: urlParameters)
    }
    
    /// Get encoded data body
    /// - Throws: Error when failed to encode body into data
    /// - Returns: Data encoded body
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
}

public extension HTTPRequestMessage {
    /// Request method
    enum Method {
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
