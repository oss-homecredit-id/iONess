//
//  DataRequestHandler.swift
//  iONess
//
//  Created by Nayanda Haberty on 02/07/21.
//

import Foundation
import Ergo

/// Status of request
public enum RequestStatus {
    case running(Float)
    case dropped
    case idle
    case completed(URLResponse)
    case error(Error)
}

/// Request Handler protocol
public protocol RequestHandler: Dropable {
    associatedtype Task: URLSessionTask
    associatedtype Result: NetworkResult
    /// status of request
    var status: RequestStatus { get }
    /// error occurs in request
    var error: Error? { get set }
    /// session task
    var task: Task? { get }
    /// request validator
    var responseValidator: ResponseValidator? { get }
    /// retry control
    var retryControl: RetryControl? { get }
    /// url request
    var request: URLRequest { get }
    /// start a request then run a completion
    /// - Parameter execute: completion to execute after request
    func doRequest(then execute: @escaping (Result) -> Void)
    /// validate request
    /// - Parameter response: response to validate
    func validate(response: URLResponse?) -> Error?
    /// Decide to retry or not
    /// - Parameters:
    ///   - error: error occurs after request
    ///   - response: response of the request
    ///   - onRetry: what to do when retry
    ///   - onNoRetry: what to when not retry
    func retryIfShould(error: Error, response: URLResponse?, onRetry: @escaping () -> Void, onNoRetry: @escaping () -> Void)
}

public extension RequestHandler {
    
    /// status of request
    var status: RequestStatus {
        guard let task = self.task else {
            return .idle
        }
        switch task.state {
        case .canceling:
            return .dropped
        case .completed:
            if let response = task.response {
                return .completed(response)
            }
            return .error(task.error ?? NetworkSessionError(description: "iONess Error: unknown error"))
        case .running:
            let expected = task.countOfBytesExpectedToSend
                + task.countOfBytesExpectedToReceive
            let actual = task.countOfBytesSent + task.countOfBytesReceived
            return .running(Float(actual) / Float(expected))
        default:
            return .idle
        }
    }
    
    /// Drop request
    /// - Parameter error: Error that make the request should drop
    func drop(becauseOf error: Error) {
        self.error = error
        task?.cancel()
    }
    
    /// validate request
    /// - Parameter response: Error if response is invalid, it will return nil if request valid
    /// - Returns: Error if response is invalid, it will return nil if request valid
    func validate(response: URLResponse?) -> Error? {
        guard let response = response else {
            return NetworkSessionError(description: "iONess Error: get no response from server")
        }
        let validation = responseValidator?.validate(for: response) ?? .valid
        switch validation {
        case .invalidWithReason(let reason):
            return NetworkSessionError(description: reason)
        case .invalid:
            return NetworkSessionError(description: "iONess Error: response invalid for unknown reason")
        default:
            return nil
        }
    }
    
    /// Decide to retry or not
    /// - Parameters:
    ///   - error: error occurs after request
    ///   - response: response of the request
    ///   - onRetry: what to do when retry
    ///   - onNoRetry: what to when not retry
    func retryIfShould(
        error: Error,
        response: URLResponse?,
        onRetry: @escaping () -> Void,
        onNoRetry: @escaping () -> Void) {
        guard !error.causeByCancel,
              let retryControl = retryControl else {
            onNoRetry()
            return
        }
        retryControl.shouldRetry(for: request, response: response, error: error) { retryStatus in
            switch retryStatus {
            case .retryAfter(let delay):
                let dispatcher: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main
                dispatcher.asyncAfter(deadline: .now() + delay, execute: onRetry)
            case .retry:
                onRetry()
            case .noRetry:
                onNoRetry()
            }
        }
    }
}

/// Data Request Handler
open class DataRequestHandler: RequestHandler {
    public typealias Result = URLResult
    public typealias Task = URLSessionDataTask
    
    /// request validator
    public let responseValidator: ResponseValidator?
    /// retry control
    public let retryControl: RetryControl?
    let networkSessionManager: NetworkSessionManager
    /// url request
    public let request: URLRequest
    /// session task
    public internal(set) var task: URLSessionDataTask?
    /// error occurs in request
    public var error: Error?
    
    /// Defaul initializer
    /// - Parameters:
    ///   - networkSessionManager: network manager
    ///   - request: url request
    ///   - responseValidator: request validator
    ///   - retryControl: retry control
    public init(
        networkSessionManager: NetworkSessionManager,
        request: URLRequest,
        responseValidator: ResponseValidator?,
        retryControl: RetryControl?) {
        self.responseValidator = responseValidator
        self.retryControl = retryControl
        self.networkSessionManager = networkSessionManager
        self.request = request
    }
    
    /// start a request then run a completion
    /// - Parameter execute: completion to execute after request
    open func doRequest(then execute: @escaping (URLResult) -> Void) {
        let task = createTask(with: execute)
        task.resume()
        self.task = task
    }
    
    func createTask(with completion: @escaping (URLResult) -> Void) -> URLSessionDataTask {
        let handler = self
        return networkSessionManager.dataTask(with: request) { data, response, error in
            guard let requestError = error ?? handler.validate(response: response) else {
                completion(.init(response: response, data: data, error: error))
                return
            }
            handler.retryIfShould(error: requestError, response: response) {
                handler.doRequest(then: completion)
            } onNoRetry: {
                completion(.init(response: response, data: data, error: error))
            }
        }
    }
}

/// Upload Request Handler
open class UploadRequestHandler: RequestHandler {
    public typealias Result = URLResult
    public typealias Task = URLSessionUploadTask
    
    let fileUrl: URL
    /// request validator
    public let responseValidator: ResponseValidator?
    /// retry control
    public let retryControl: RetryControl?
    let networkSessionManager: NetworkSessionManager
    /// url request
    public let request: URLRequest
    /// session task
    public internal(set) var task: URLSessionUploadTask?
    /// error occurs in request
    public var error: Error?
    
    /// Defaul initializer
    /// - Parameters:
    ///   - networkSessionManager: network manager
    ///   - request: url request
    ///   - fileUrl: url of file for upload
    ///   - responseValidator: request validator
    ///   - retryControl: retry control
    public init(
        networkSessionManager: NetworkSessionManager,
        request: URLRequest,
        fileUrl: URL,
        responseValidator: ResponseValidator?,
        retryControl: RetryControl?) {
        self.fileUrl = fileUrl
        self.responseValidator = responseValidator
        self.retryControl = retryControl
        self.networkSessionManager = networkSessionManager
        self.request = request
    }
    
    /// start a request then run a completion
    /// - Parameter execute: completion to execute after request
    open func doRequest(then execute: @escaping (URLResult) -> Void) {
        let task = createTask(with: execute)
        task.resume()
        self.task = task
    }
    
    func createTask(with completion: @escaping (URLResult) -> Void) -> URLSessionUploadTask {
        let handler = self
        return networkSessionManager.uploadTask(with: request, fromFile: fileUrl) { data, response, error in
            guard let requestError = error ?? handler.validate(response: response) else {
                completion(.init(response: response, data: data, error: error))
                return
            }
            handler.retryIfShould(error: requestError, response: response) {
                handler.doRequest(then: completion)
            } onNoRetry: {
                completion(.init(response: response, data: data, error: error))
            }
        }
    }
}

/// Download Request Handler
open class DownloadRequestHandler: RequestHandler, Resumable {
    public typealias Result = DownloadResult
    public typealias Task = URLSessionDownloadTask
    
    var dataInProgress: Data?
    let targetUrl: URL
    /// request validator
    public let responseValidator: ResponseValidator?
    /// retry control
    public let retryControl: RetryControl?
    let networkSessionManager: NetworkSessionManager
    /// url request
    public let request: URLRequest
    /// session task
    public internal(set) var task: URLSessionDownloadTask?
    private var lastCompletion: ((DownloadResult) -> Void)?
    /// error occurs in request
    public var error: Error?
    
    /// Defaul initializer
    /// - Parameters:
    ///   - networkSessionManager: network manager
    ///   - request: url request
    ///   - targetUrl: url of file after download
    ///   - responseValidator: request validator
    ///   - retryControl: retry control
    public init(
        networkSessionManager: NetworkSessionManager,
        request: URLRequest,
        targetUrl: URL,
        responseValidator: ResponseValidator?,
        retryControl: RetryControl?) {
        self.targetUrl = targetUrl
        self.responseValidator = responseValidator
        self.retryControl = retryControl
        self.networkSessionManager = networkSessionManager
        self.request = request
    }
    
    /// start a request then run a completion
    /// - Parameter execute: completion to execute after request
    open func doRequest(then execute: @escaping (DownloadResult) -> Void) {
        let task = createTask(with: execute)
        task.resume()
        self.task = task
    }
    
    /// pause the request
    open func pause() {
        task?.cancel { [weak self] data in
            self?.dataInProgress = data
        }
    }
    
    /// try to resume the request
    /// - Returns: resume status
    open func resume() -> ResumeStatus {
        guard let completion = lastCompletion else {
            return .failToResume
        }
        doRequest(then: completion)
        return .resumed
    }
    
    func moveResult(from url: URL?, response: URLResponse?) -> Error? {
        do {
            guard let url = url else {
                throw NetworkSessionError(
                    statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
                    description: "iONess Error: data failed to download"
                )
            }
            try FileManager.default.moveItem(at: url, to: targetUrl)
            return nil
        } catch {
            return error
        }
    }
    
    func createTask(with completion: @escaping (DownloadResult) -> Void) -> URLSessionDownloadTask {
        let handler = self
        return networkSessionManager.downloadTask(with: request, resumeData: dataInProgress) { tempUrl, response, error in
            guard let error = error ?? (
                    handler.moveResult(from: tempUrl, response: response)
                        ?? handler.validate(response: response)) else {
                completion(.init(response: response, dataLocalURL: handler.targetUrl, error: error))
                return
            }
            handler.retryIfShould(error: error, response: response) {
                handler.doRequest(then: completion)
            } onNoRetry: {
                completion(.init(response: response, dataLocalURL: handler.targetUrl, error: error))
            }
        }
    }
}
