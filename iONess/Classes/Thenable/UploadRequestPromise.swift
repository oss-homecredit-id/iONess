//
//  UploadRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class UploadRequestPromise: HTTPRequestPromise<URLResponse, URLResult> {
    var fileURL: URL
    
    public init(request: HTTPRequestMessage, with session: URLSession, retryControl: RetryControl?, fileURL: URL) throws {
        self.fileURL = fileURL
        try super.init(request: request, with: session, retryControl: retryControl)
    }
    
    @discardableResult
    open override func then(run closure: @escaping (URLResult) -> Void) -> DropableURLRequest<Response> {
        let dispatcher = self.dispatcher
        return DropableUploadRequest(
            session: urlSession,
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
