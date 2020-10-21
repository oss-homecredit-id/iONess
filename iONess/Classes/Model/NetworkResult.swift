//
//  URLResult.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol NetworkResult {
    var urlResponse: URLResponse? { get }
    var error: Error? { get }
    var isFailed: Bool { get }
    var isSucceed: Bool { get }
    init(error: Error)
}

public extension NetworkResult {
    var isFailed: Bool {
        error != nil || urlResponse == nil
    }
    var isSucceed: Bool {
        !isFailed
    }
}

public struct URLResult: NetworkResult {
    public let urlResponse: URLResponse?
    public let responseData: Data?
    public let error: Error?
    public var httpMessage: HTTPResultMessage? {
        guard let response = urlResponse as? HTTPURLResponse else { return nil }
        return .init(httpResponse: response, body: responseData)
    }
    
    public init(response: URLResponse?, data: Data?, error: Error?) {
        self.urlResponse = response
        self.responseData = data
        self.error = error
    }
    
    public init(error: Error) {
        self.init(response: nil, data: nil, error: error)
    }
}

public struct DownloadResult: NetworkResult {
    public let urlResponse: URLResponse?
    public let dataLocalURL: URL?
    public let error: Error?
    public var isFailed: Bool {
        error != nil || urlResponse == nil || dataLocalURL == nil
    }
    func getURL() throws -> URL {
        guard let url = dataLocalURL else {
            throw NetworkSessionError(description: "iONess Error: no URL")
        }
        return url
    }
    public func getDownloadedData() throws -> Data {
        return try .init(contentsOf: getURL())
    }
    func getDataStream() throws -> InputStream {
        guard let stream = InputStream(url: try getURL()) else {
            throw NetworkSessionError(description: "iONess Error: failed to get InputStream")
        }
        return stream
    }
    
    public init(response: URLResponse?, dataLocalURL: URL?, error: Error?) {
        self.urlResponse = response
        self.dataLocalURL = dataLocalURL
        self.error = error
    }
    
    public init(error: Error) {
        self.init(response: nil, dataLocalURL: nil, error: error)
    }
}
