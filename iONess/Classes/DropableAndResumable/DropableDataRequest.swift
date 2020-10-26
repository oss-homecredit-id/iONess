//
//  DropableDataRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public class DropableDataRequest<Response: URLResponse>: BaseDropableURLRequest<Response, URLResult> {
    var task: URLSessionDataTask!
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
    
    init(networkSessionManager: NetworkSessionManager,
         request: URLRequest,
         retryControl: RetryControl?,
         urlValidator: URLValidator?,
         completion: @escaping (URLResult) -> Void) {
        super.init(
            networkSessionManager: networkSessionManager,
            request: request,
            urlValidator: urlValidator,
            retryControl: retryControl,
            completion: completion
        )
        task = Self.request(
            for: self,
            in: networkSessionManager,
            with: request,
            retryControl,
            urlValidator,
            completion
        )
    }
    
    public override func drop() {
        task.cancel()
    }
    
    static func request(
        for dropable: DropableDataRequest?,
        in networkSessionManager: NetworkSessionManager,
        with request: URLRequest,
        _ retryControl: RetryControl?,
        _ validator: URLValidator?,
        _ completion: @escaping (URLResult) -> Void) -> URLSessionDataTask {
        networkSessionManager.dataTask(with: request) { [weak dropable] data, response, error in
            guard let requestError = error ?? validate(response: response, with: validator) else {
                completion(
                    .init(
                        response: response,
                        data: data,
                        error: error
                    )
                )
                return
            }
            retryIfShould(
                with: retryControl,
                error: requestError,
                request: request,
                response, {
                    dropable?.task = Self.request(
                        for: dropable,
                        in: networkSessionManager,
                        with: request,
                        retryControl,
                        validator,
                        completion
                    )
                }, onNoRetry: {
                    completion(
                        .init(
                            response: response,
                            data: data,
                            error: error
                        )
                    )
                }
            )
        }
    }
}
