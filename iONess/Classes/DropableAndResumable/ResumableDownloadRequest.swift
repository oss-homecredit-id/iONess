//
//  ResumableDownloadRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public class ResumableDownloadRequest: BaseDropableURLRequest<URLResponse, DownloadResult>, Resumable {
    let targetUrl: URL
    var dataInProgress: Data?
    var task: URLSessionDownloadTask!
    
    public override var status: DropableStatus<Response> {
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
    
    init(networkSessionManager: NetworkSessionManager,
         request: URLRequest,
         targetUrl: URL,
         retryControl: RetryControl?,
         urlValidator: URLValidator?,
         completion: @escaping (DownloadResult) -> Void) {
        self.targetUrl = targetUrl
        super.init(
            networkSessionManager: networkSessionManager,
            request: request,
            urlValidator: urlValidator,
            retryControl: retryControl,
            completion: completion
        )
        task = Self.download(
            for: self,
            resumeData: nil,
            in: networkSessionManager,
            with: request,
            targetUrl: targetUrl,
            retryControl,
            urlValidator,
            completion
        )
    }
    
    public override func drop() {
        task.cancel()
    }
    
    public func pause() {
        task.cancel { [weak self] data in
            self?.dataInProgress = data
        }
    }
    
    public func resume() -> ResumeStatus {
        guard let data = dataInProgress else {
            return .failToResume
        }
        task = Self.download(
            for: self,
            resumeData: data,
            in: networkSessionManager,
            with: request,
            targetUrl: targetUrl,
            retryControl,
            urlValidator,
            completion
        )
        return .resumed
    }
    
    static func download(
        for dropable: ResumableDownloadRequest?,
        resumeData: Data? = nil,
        in networkSessionManager: NetworkSessionManager,
        with request: URLRequest,
        targetUrl: URL,
        _ retryControl: RetryControl?,
        _ validator: URLValidator?,
        _ completion: @escaping (DownloadResult) -> Void) -> URLSessionDownloadTask {
        let downloadCompletion: (URL?, URLResponse?, Error?) -> Void = { [weak dropable] url, response, error in
            var shouldRunCompletion: Bool = true
            var currentError: Error?
            do {
                if let downloadError = error {
                    throw downloadError
                }
                guard let url = url else {
                    throw NetworkSessionError(
                        statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
                        description: "iONess Error: data failed to download"
                    )
                }
                try FileManager.default.moveItem(at: url, to: targetUrl)
            } catch {
                currentError = error
            }
            if let currentError = currentError ?? validate(response: response, with: validator) {
                let retried = retryIfShould(with: retryControl, error: currentError, request: request, response) {
                    dropable?.task = Self.download(
                        for: dropable,
                        in: networkSessionManager,
                        with: request,
                        targetUrl: targetUrl,
                        retryControl,
                        validator,
                        completion
                    )
                }
                shouldRunCompletion = !retried
            }
            guard shouldRunCompletion else { return }
            completion(
                .init(
                    response: response,
                    dataLocalURL: targetUrl,
                    error: currentError
                )
            )
        }
        guard let data = resumeData else {
            return networkSessionManager.downloadTask(with: request, completionHandler: downloadCompletion)
        }
        return networkSessionManager.session.downloadTask(withResumeData: data, completionHandler: downloadCompletion)
    }
}
