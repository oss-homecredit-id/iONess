//
//  DownloadRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class DownloadRequestPromise: HTTPRequestPromise<URLResponse, DownloadResult> {
    var targetUrl: URL
    
    public init(request: HTTPRequestMessage, with session: URLSession, retryControl: RetryControl?, targetUrl: URL) throws {
        self.targetUrl = targetUrl
        try super.init(request: request, with: session, retryControl: retryControl)
    }
    
    @discardableResult
    open override func then(run closure: @escaping (DownloadResult) -> Void) -> DropableURLRequest<Response> {
        let dispatcher = self.dispatcher
        return ResumableDownloadRequest(
            session: urlSession,
            request: urlRequest,
            targetUrl: targetUrl,
            retryControl: retryControl,
            urlValidator: urlValidator) { result in
                dispatcher.async {
                    closure(result)
                }
        }
    }
}
