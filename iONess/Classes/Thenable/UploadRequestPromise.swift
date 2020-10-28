//
//  UploadRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Thenable HTTPRequest for uploading data
open class UploadRequestPromise: HTTPRequestPromise<URLResponse, URLResult> {
    var fileURL: URL
    
    /// Default init
    /// - Parameters:
    ///   - request: HTTPRequestMessage object which describe the request
    ///   - networkSessionManager: NetworkSessionManager object
    ///   - retryControl: RetryControl object
    ///   - fileURL: local URL file which will be uploaded
    /// - Throws: Error when generating URLRequest from HTTPRequestMessage
    public init(request: HTTPRequestMessage, with networkSessionManager: NetworkSessionManager, retryControl: RetryControl?, fileURL: URL) throws {
        self.fileURL = fileURL
        try super.init(request: request, with: networkSessionManager, retryControl: retryControl)
    }
    
    /// Method to run closure after the request is finished.
    /// - Parameter closure: closure which will be run when the request is finished
    /// - Returns: DropableURLRequest<Response> object
    @discardableResult
    open override func then(run closure: @escaping (URLResult) -> Void) -> DropableURLRequest<Response> {
        let dispatcher = self.dispatcher
        return DropableUploadRequest(
            networkSessionManager: networkSessionManager,
            request: urlRequest,
            fileUrl: fileURL,
            retryControl: retryControl,
            urlValidator: urlValidator) { result in
                dispatcher.async {
                    closure(result)
                }
        }
    }
}
