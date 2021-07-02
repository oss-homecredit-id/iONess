//
//  NetworkSessionError.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Base Error Protocol for iONess
public protocol NetworkSessionErrorProtocol: LocalizedError {
    /// orignal error if have any
    var originalError: Error? { get }
    /// status code of the error
    var statusCode: Int { get }
}

public typealias NessError = NetworkSessionError

/// Network Session Error Object
public final class NetworkSessionError: NSError, NetworkSessionErrorProtocol {
    
    /// List of HTTP Error Code Error
    public static let statusCodeMesage: [Int: String] = [
        NSURLErrorCancelled: "Request Canceled",
        NSURLErrorUnknown: "Unknown Error",
        203: "Non-Authoritative Information (since HTTP/1.1)",
        204: "No Content",
        205: "Reset Content",
        206: "Partial Content",
        207: "Multi-Status",
        208: "Already Reported",
        226: "IM Used",
        300: "Multiple Choices",
        301: "Moved Permanently",
        304: "Not Modified",
        305: "Use Proxy",
        306: "Switch Proxy",
        307: "Temporary Redirected",
        308: "Permanent Redirected (Experimental RFC; RFC 7238)",
        400: "Bad Request",
        401: "Unauthorized",
        402: "Payment Required",
        403: "Forbidden",
        404: "Not Found",
        405: "Method Not Allowed",
        406: "Not Acceptable",
        407: "Proxy Authentication Required",
        408: "Request Timeout",
        409: "Conflict",
        410: "Gone",
        411: "Length Required",
        412: "Precondition Failed",
        413: "Request Entity Too Large",
        414: "Request-URI Too Long",
        415: "Unsupported Media Type",
        416: "Requested Range Not Satisfiable",
        417: "Expectation Failed",
        419: "Authentication Timeout (not in RFC 2616)",
        420: "Method Failure (Spring Framework)",
        500: "Internal Server Error",
        501: "Not Implemented",
        502: "Bad Gateway",
        503: "Service Unavailable",
        504: "Gateway Timeout",
        505: "HTTP Version Not Supported",
        506: "Variant Also Negotiates (RFC 2295)",
        507: "Insufficient Storage (WebDAV; RFC 4918)",
        508: "Loop Detected (WebDAV; RFC 5842)",
        509: "Bandwidth Limit Exceeded (Apache bw/limited extension)",
        510: "Not Extended (RFC 2774)",
        511: "Network Authentication Required (RFC 6585)",
        520: "Origin Error (CloudFlare)",
        521: "Web server is down (CloudFlare)",
        522: "Connection timed out (CloudFlare)",
        523: "Proxy Declined Request (CloudFlare)",
        524: "A timeout occurred (CloudFlare)",
        598: "Network read timeout error (Unknown)"
    ]
    
    /// orignal error if have any
    public private(set) var originalError: Error?
    
    /// status code of the error
    public var statusCode: Int { code }
    
    /// description of the error
    public var errorDescription: String? { localizedDescription }
    
    init(originalError: Error? = nil, statusCode: Int? = nil, description: String? = nil) {
        self.originalError = originalError
        let code = (statusCode ?? (originalError as NSError?)?.code) ?? NSURLErrorUnknown
        let desc: String = description ?? (NetworkSessionError.statusCodeMesage[code] ?? "Unknown Custom Error")
        super.init(domain: "homecredit.co.id.ioness", code: code, userInfo: [NSLocalizedDescriptionKey: desc])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension Error {
    /// will be true if the error code is NSURLErrorCancelled
    var causeByCancel: Bool { (self as NSError).code == NSURLErrorCancelled }
}
