//
//  DropableDataRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public class DropableDataRequest<Response: URLResponse>: BaseDropableURLRequest<Response, URLResult> {
    lazy var task: URLSessionDataTask = Self.request(
        for: self,
        in: session,
        with: request,
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
         retryControl: RetryControl?,
         urlValidator: URLValidator?,
         completion: @escaping (URLResult) -> Void) {
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
    
    static func request(
        for dropable: DropableDataRequest?,
        in session: URLSession,
        with request: URLRequest,
        _ retryControl: RetryControl?,
        _ validator: URLValidator?,
        _ completion: @escaping (URLResult) -> Void) -> URLSessionDataTask {
        session.dataTask(with: request) { [weak dropable] data, response, error in
            if let requestError = error ?? validate(response: response, with: validator) {
                retryIfShould(with: retryControl, error: requestError, request: request, response) {
                    dropable?.task = Self.request(
                        for: dropable,
                        in: session,
                        with: request,
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
