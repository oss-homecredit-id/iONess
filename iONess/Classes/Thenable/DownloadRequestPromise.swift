//
//  DownloadRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class DownloadRequestPromise: HTTPRequestPromise<URLResponse, DownloadResult> {
    var targetUrl: URL
    
    public init(request: HTTPRequestMessage, with networkSessionManager: NetworkSessionManager, retryControl: RetryControl?, targetUrl: URL) throws {
        self.targetUrl = targetUrl
        try super.init(request: request, with: networkSessionManager, retryControl: retryControl)
    }
    
    @discardableResult
    open override func then(run closure: @escaping (DownloadResult) -> Void) -> DropableURLRequest<Response> {
        let dispatcher = self.dispatcher
        return ResumableDownloadRequest(
            networkSessionManager: networkSessionManager,
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
