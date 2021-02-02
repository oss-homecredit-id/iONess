//
//  DownloadRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Thenable HTTPRequest for downloading data
open class DownloadRequestPromise: HTTPRequestPromise<URLResponse, DownloadResult> {
    var targetUrl: URL
    
    /// Default Init
    /// - Parameters:
    ///   - request: HTTPRequestMessage object which describe the request
    ///   - networkSessionManager: NetworkSessionManager object
    ///   - retryControl: RetryControl object
    ///   - targetUrl: local URL file which data will be downloaded
    /// - Throws: Error when generating URLRequest from HTTPRequestMessage
    public init(request: HTTPRequestMessage, with networkSessionManager: NetworkSessionManager, retryControl: RetryControl?, targetUrl: URL) throws {
        self.targetUrl = targetUrl
        try super.init(request: request, with: networkSessionManager, retryControl: retryControl)
    }
    
    /// Method to run closure after the request is finished.
    /// - Parameter closure: closure which will be run when the request is finished
    /// - Returns: DropableURLRequest<Response> object
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
