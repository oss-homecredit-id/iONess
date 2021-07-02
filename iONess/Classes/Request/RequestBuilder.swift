//
//  RequestBuilder.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation
import Ergo

/// Request Builder
open class RequestBuilder {
    var responseValidator: ResponseValidator?
    var retryControl: RetryControl?
    var httpRequest: HTTPRequestMessage
    var networkSessionManager: NetworkSessionManager
    
    /// Default init
    /// - Parameters:
    ///   - method: HTTP request method
    ///   - url: URL of request
    ///   - networkSessionManager: network manager
    public init(method: HTTPRequestMessage.Method = .none, with url: URLCompatible, networkSessionManager: NetworkSessionManager) {
        self.networkSessionManager = networkSessionManager
        httpRequest = .init()
        httpRequest.url = url
        httpRequest.method = method
    }
    
    /// Set data as HTTP request body
    /// - Parameter body: Data
    /// - Returns: RequestBuilder itself
    open func set(body: Data) -> Self {
        httpRequest.body = body
        return self
    }
    
    /// Set String as HTTP request body
    /// - Parameters:
    ///   - stringBody: String
    ///   - encoding: type of encoding
    /// - Returns: RequestBuilder itself
    open func set(stringBody: String, encoding: String.Encoding = .utf8) -> Self {
        httpRequest.encodedBody = stringBody
        httpRequest.encoder = StringBodyEncoder(encoding: encoding)
        return self
    }
    
    /// Set any object to be encoded by encoder as HTTP Request body
    /// - Parameters:
    ///   - body: any object
    ///   - encoder: RequestBodyEncoder
    /// - Returns: RequestBuilder itself
    open func set(body: Any, with encoder: RequestBodyEncoder) -> Self {
        httpRequest.encodedBody = body
        httpRequest.encoder = encoder
        return self
    }
    
    /// Set Dictionary represent JSON as HTTP Request body
    /// - Parameter jsonBody: JSON Dictionary
    /// - Returns: RequestBuilder itself
    open func set(jsonBody: [String: Any]) -> Self {
        httpRequest.encodedBody = jsonBody
        httpRequest.encoder = JSONBodyEncoder()
        return self
    }
    
    /// Set Array of JSON Compatible type as HTTP Request body
    /// - Parameter arrayJsonBody: Array of JSON Compatible type
    /// - Returns: RequestBuilder itself
    open func set(arrayJsonBody: [Any]) -> Self {
        httpRequest.encodedBody = arrayJsonBody
        httpRequest.encoder = JSONArrayBodyEncoder()
        return self
    }
    
    /// Set header to HTTP Request
    /// - Parameters:
    ///   - option: SetOption
    ///   - headers: HTTP Request Header
    /// - Returns: RequestBuilder itself
    open func set(_ option: SetOption = .overwriteAll, headers: HTTPRequestMessage.Header) -> Self {
        set(dictionary: &httpRequest.headers, option, headers)
        return self
    }
    
    /// Add header to HTTP Request
    /// - Parameters:
    ///   - value: value of header
    ///   - key: key of header
    /// - Returns: RequestBuilder itself
    open func add(headerValue value: String, forKey key: String) -> Self {
        httpRequest.headers[key] = value
        return self
    }
    
    /// Set URL Parameters to HTTP Request
    /// - Parameters:
    ///   - option: SetOption
    ///   - urlParameters: HTTP URL Parameters
    /// - Returns: RequestBuilder itself
    open func set(_ option: SetOption = .overwriteAll, urlParameters: HTTPRequestMessage.URLParameters) -> Self {
        set(dictionary: &httpRequest.urlParameters, option, urlParameters)
        return self
    }
    
    /// Add URL Parameters to HTTP Request
    /// - Parameters:
    ///   - value: value of parameters
    ///   - key: key of parameters
    /// - Returns: RequestBuilder itself
    open func add(urlParameterValue value: String, forKey key: String) -> Self {
        httpRequest.urlParameters[key] = value
        return self
    }
    
    /// Method to add custom ResponseValidator
    /// - Parameter validator: custom ResponseValidator
    /// - Returns: RequestBuilder which have custom ResponseValidator combined with previous validator if have any
    open func validate(using validator: ResponseValidator) -> Self {
        guard let current = responseValidator else {
            responseValidator = validator
            return self
        }
        responseValidator = current.combine(with: validator)
        return self
    }
    
    /// Create DataPromise with builded HTTP Request. It will automatically run the request
    /// - Parameter retryControl: Retry Control
    /// - Returns: DataPromise
    open func dataRequest(with retryControl: RetryControl? = nil) -> DataPromise {
        DataPromise(request: httpRequest, with: networkSessionManager, retryControl: retryControl, validator: responseValidator)
    }
    
    /// Create UploadPromise with builded HTTP Request. It will automatically run the request
    /// - Parameters:
    ///   - url: file to upload
    ///   - retryControl: Retry Control
    /// - Returns: UploadPromise
    open func uploadRequest(forFileLocation url: URL, with retryControl: RetryControl? = nil) -> UploadPromise {
        UploadPromise(request: httpRequest, fileUrl: url, with: networkSessionManager, retryControl: retryControl, validator: responseValidator)
    }
    
    /// Create DownloadPromise with builded HTTP Request. It will automatically run the request
    /// - Parameters:
    ///   - url: file downloaded location
    ///   - retryControl: Retry Control
    /// - Returns: DownloadPromise
    open func downloadRequest(forSavedLocation url: URL, with retryControl: RetryControl? = nil) -> DownloadPromise {
        DownloadPromise(request: httpRequest, targetUrl: url, with: networkSessionManager, retryControl: retryControl, validator: responseValidator)
    }
    
    func set(dictionary: inout [String: String], _ option: RequestBuilder.SetOption, _ newDictionary: [String: String]) {
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
}

public extension RequestBuilder {
    
    /// Set Option
    enum SetOption {
        case overwriteAll
        case appendAndOverwriteSamekey
        case appendAndKeepPreviousValue
    }
}

public extension RequestBuilder {
    
    /// Method to add ResponseValidator which validate using status code
    /// - Parameter statusCode: valid status code
    /// - Returns: RequestBuilder which have status code ResponseValidator combined with previous validator if have any
    func validate(statusCode: Int) -> Self {
        return validate(statusCodes: statusCode..<statusCode + 1)
    }
    
    /// Method to add ResponseValidator which validate using status codes
    /// - Parameter statusCodes: valid status codes
    /// - Returns: RequestBuilder which have status codes ResponseValidator combined with previous validator if have any
    func validate(statusCodes: Range<Int>) -> Self {
        validate(using: StatusCodeValidator(statusCodes))
    }
    
    /// Method to add ResponseValidator which validate result headers
    /// - Parameter headers: valid result headers
    /// - Returns: RequestBuilder which have headers ResponseValidator combined with previous validator if have any
    func validate(shouldHaveHeaders headers: [String:String]) -> Self {
        validate(using: HeaderValidator(.shouldContains, headers))
    }
    
    /// Method to add ResponseValidator which validate result headers
    /// - Parameters:
    ///   - validation: type of validation
    ///   - header: header to match
    /// - Returns: RequestBuilder which have headers ResponseValidator combined with previous validator if have any
    func validate(_ validation: HeaderValidator.Validation, _ headers: [String: String]) -> Self {
        validate(using: HeaderValidator(validation, headers))
    }
    
    /// Set encodable object as JSON Body of HTTP Request
    /// - Parameter jsonEncodable: object to encode
    /// - Returns: RequestBuilder itself
    func set<EObject: Encodable>(jsonEncodable: EObject) -> Self {
        httpRequest.encodedBody = jsonEncodable
        httpRequest.encoder = JSONEncodableBodyEncoder(forType: EObject.self)
        return self
    }
    
    /// Set array of encodable object as JSON Body of HTTP Request
    /// - Parameter arrayJsonEncodable: array of encodable object to encode
    /// - Returns: RequestBuilder itself
    func set<EObject: Encodable>(arrayJsonEncodable: [EObject]) -> Self {
        httpRequest.encodedBody = arrayJsonEncodable
        httpRequest.encoder = JSONArrayEncodableBodyEncoder(forType: EObject.self)
        return self
    }
}
