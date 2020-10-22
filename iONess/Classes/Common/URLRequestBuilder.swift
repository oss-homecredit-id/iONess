//
//  URLRequestBuilder.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class URLRequestBuilder {
    private var httpRequest: HTTPRequestMessage
    var networkSessionManager: NetworkSessionManager
    
    init(method: HTTPRequestMessage.Method = .none, with url: URLCompatible, networkSessionManager: NetworkSessionManager) {
        self.networkSessionManager = networkSessionManager
        httpRequest = .init()
        httpRequest.url = url
        httpRequest.method = method
    }
    
    open func set(body: Data) -> Self {
        httpRequest.body = body
        return self
    }
    
    open func set(stringBody: String, encoding: String.Encoding = .utf8) -> Self {
        httpRequest.encodedBody = stringBody
        httpRequest.encoder = StringBodyEncoder(encoding: encoding)
        return self
    }
    
    open func set(body: Any, with encoder: HTTPBodyEncoder) -> Self {
        httpRequest.encodedBody = body
        httpRequest.encoder = encoder
        return self
    }
    
    open func set(jsonBody: [String: Any]) -> Self {
        httpRequest.encodedBody = jsonBody
        httpRequest.encoder = JSONBodyEncoder()
        return self
    }
    
    open func set(arrayJsonBody: [Any]) -> Self {
        httpRequest.encodedBody = arrayJsonBody
        httpRequest.encoder = JSONArrayBodyEncoder()
        return self
    }
    
    open func set(_ option: SetOption = .overwriteAll, headers: HTTPRequestMessage.Header) -> Self {
        set(dictionary: &httpRequest.headers, option, headers)
        return self
    }
    
    open func add(headerValue value: String, forKey key: String) -> Self {
        httpRequest.headers[key] = value
        return self
    }
    
    open func set(_ option: SetOption = .overwriteAll, urlParameters: HTTPRequestMessage.URLParameters) -> Self {
        set(dictionary: &httpRequest.urlParameters, option, urlParameters)
        return self
    }
    
    open func add(urlParameterValue value: String, forKey key: String) -> Self {
        httpRequest.urlParameters[key] = value
        return self
    }
    
    private func set(dictionary: inout [String: String], _ option: URLRequestBuilder.SetOption, _ newDictionary: [String: String]) {
        switch option {
        case .overwriteAll:
            dictionary = newDictionary
        case .appendAndOverwriteSamekey:
            for member in newDictionary {
                dictionary[member.key] = member.value
            }
        case .appendAndKeepPreviousValue:
            for member in newDictionary where !dictionary.keys.contains(member.key) {
                dictionary[member.key] = member.value
            }
        }
    }
    
    open func prepareDataRequest(with retryControl: RetryControl? = nil) -> URLRequestPromise<HTTPURLResponse, URLResult> {
        tryGetRequest(
            try DataRequestPromise(request: httpRequest, with: networkSessionManager, retryControl: retryControl)
        )
    }
    
    open func prepareDownloadRequest(targetSavedLocation url: URL, with retryControl: RetryControl? = nil) -> URLRequestPromise<URLResponse, DownloadResult> {
        tryGetRequest(
            try DownloadRequestPromise(request: httpRequest, with: networkSessionManager, retryControl: retryControl, targetUrl: url)
        )
    }
    
    open func prepareUploadRequest(withFileLocation url: URL, with retryControl: RetryControl? = nil) -> URLRequestPromise<URLResponse, URLResult> {
        return tryGetRequest(
            try UploadRequestPromise(request: httpRequest, with: networkSessionManager, retryControl: retryControl, fileURL: url)
        )
    }
    
    func tryGetRequest<Response: URLResponse, Result: NetworkResult>(_ getter: @autoclosure () throws -> URLRequestPromise<Response, Result>) -> URLRequestPromise<Response, Result> {
        do {
            return try getter()
        }
        catch {
            return ErrorRequestPromise(error: error)
        }
    }
    
    public enum SetOption {
        case overwriteAll
        case appendAndOverwriteSamekey
        case appendAndKeepPreviousValue
    }
}

// MARK: Encodable Body

public extension URLRequestBuilder {
    func set<EObject: Encodable>(jsonEncodable: EObject) -> Self {
        httpRequest.encodedBody = jsonEncodable
        httpRequest.encoder = JSONEncodableBodyEncoder(forType: EObject.self)
        return self
    }
    
    func set<EObject: Encodable>(arrayJsonEncodable: [EObject]) -> Self {
        httpRequest.encodedBody = arrayJsonEncodable
        httpRequest.encoder = JSONArrayEncodableBodyEncoder(forType: EObject.self)
        return self
    }
}
