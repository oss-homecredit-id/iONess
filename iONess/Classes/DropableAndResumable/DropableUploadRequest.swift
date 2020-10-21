//
//  DropableUploadRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public class DropableUploadRequest<Response: URLResponse>: BaseDropableURLRequest<Response, URLResult> {
    let fileUrl: URL
    lazy var task: URLSessionUploadTask = Self.upload(
        for: self,
        in: session,
        with: request,
        fromFile: fileUrl,
        retryControl,
        urlValidator,
        completion
    )
    public override var status: DropableStatus<Response> {
        switch task.state {
        case .canceling:
            return .dropped
        case .completed:
            if let response = task.response as? Response {
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
    
    init(session: URLSession,
         request: URLRequest,
         fileUrl: URL,
         retryControl: RetryControl?,
         urlValidator: URLValidator?,
         completion: @escaping (URLResult) -> Void) {
        self.fileUrl = fileUrl
        super.init(
            session: session,
            request: request,
            urlValidator: urlValidator,
            retryControl: retryControl,
            completion: completion
        )
        task.resume()
    }
    
    public override func drop() {
        task.cancel()
    }
    
    static func upload(
        for promise: DropableUploadRequest,
        in session: URLSession,
        with request: URLRequest,
        fromFile url: URL,
        _ retryControl: RetryControl?,
        _ validator: URLValidator?,
        _ completion: @escaping (URLResult) -> Void) -> URLSessionUploadTask {
        session.uploadTask(with: request, fromFile: url) { data, response, error in
            if let requestError = error ?? validate(response: response, with: validator) {
                retryIfShould(with: retryControl, error: requestError, request: request, response) {
                    promise.task = Self.upload(
                        for: promise,
                        in: session,
                        with: request,
                        fromFile: url,
                        retryControl,
                        validator,
                        completion
                    )
                }
                return
            }
            completion(
                .init(
                    response: response,
                    data: data,
                    error: error
                )
            )
        }
    }
}
