//
//  URLResult.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// NetworkResult Protocol
public protocol NetworkResult {
    /// Network request response
    var urlResponse: URLResponse? { get }
    /// Network request error
    var error: Error? { get }
    /// will be true if the request fail
    var isFailed: Bool { get }
    /// will be true if the request succeed
    var isSucceed: Bool { get }
    /// init if the request is fail
    /// - Parameter error: Error occurs on request
    init(error: Error)
}

public extension NetworkResult {
    /// will be true if the request fail
    var isFailed: Bool {
        error != nil || urlResponse == nil
    }
    /// will be true if the request succeed
    var isSucceed: Bool {
        !isFailed
    }
}

/// Basic NetworkResult object
public struct URLResult: NetworkResult {
    /// Network request response
    public let urlResponse: URLResponse?
    /// body of the response if have any
    public let responseData: Data?
    /// Network request error
    public let error: Error?
    /// HTTPResultMessage object which parsed most of response
    public var httpMessage: HTTPResultMessage? {
        guard let response = urlResponse as? HTTPURLResponse else { return nil }
        return .init(httpResponse: response, body: responseData)
    }
    
    /// Default init
    /// - Parameters:
    ///   - response: URLResponse from request
    ///   - data: body of the response if have any
    ///   - error: Network request error
    public init(response: URLResponse?, data: Data?, error: Error?) {
        self.urlResponse = response
        self.responseData = data
        self.error = error
    }
    
    /// init if the request is fail
    /// - Parameter error: Error occurs on request
    public init(error: Error) {
        self.init(response: nil, data: nil, error: error)
    }
}

/// NetworkResult object for downloading data
public struct DownloadResult: NetworkResult {
    /// Network request response
    public let urlResponse: URLResponse?
    /// local URL of downloaded data
    public let dataLocalURL: URL?
    /// Network request error
    public let error: Error?
    /// will be true if the request fail
    public var isFailed: Bool {
        error != nil || urlResponse == nil || dataLocalURL == nil
    }
    
    func getURL() throws -> URL {
        guard let url = dataLocalURL else {
            throw NetworkSessionError(description: "iONess Error: no URL")
        }
        return url
    }
    /// Method to get downloaded Data, just don't use this method if the data is big, since it will create Data object in the memory
    /// use `getDataStream()` instead
    /// - Throws: Error if the url is not present
    /// - Returns: Data object
    public func getDownloadedData() throws -> Data {
        return try .init(contentsOf: getURL())
    }
    /// Method to get downloaded Data stream
    /// - Throws: <#description#>
    /// - Returns: <#description#>
    func getDataStream() throws -> InputStream {
        guard let stream = InputStream(url: try getURL()) else {
            throw NetworkSessionError(description: "iONess Error: failed to get InputStream")
        }
        return stream
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - response: <#response description#>
    ///   - dataLocalURL: <#dataLocalURL description#>
    ///   - error: <#error description#>
    public init(response: URLResponse?, dataLocalURL: URL?, error: Error?) {
        self.urlResponse = response
        self.dataLocalURL = dataLocalURL
        self.error = error
    }
    
    /// <#Description#>
    /// - Parameter error: <#error description#>
    public init(error: Error) {
        self.init(response: nil, dataLocalURL: nil, error: error)
    }
}
