//
//  DataRequestPromise.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

open class DataRequestPromise<Response: URLResponse>: HTTPRequestPromise<Response, URLResult> {
    
    @discardableResult
    open override func then(run closure: @escaping (URLResult) -> Void) -> DropableURLRequest<Response> {
        let dispatcher = self.dispatcher
        return DropableDataRequest(
            session: urlSession,
            request: urlRequest,
            retryControl: retryControl,
            urlValidator: urlValidator) { result in
                dispatcher.async {
                    closure(result)
                }
        }
    }
}
