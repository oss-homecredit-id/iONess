//
//  NetworkRequest.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

infix operator =~

class NetworkRequest: Hashable {
    
    var request: URLRequest
    var task: URLSessionTask
    
    init(request: URLRequest, task: URLSessionTask) {
        self.request = request
        self.task = task
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(request.url)
        hasher.combine(request.allHTTPHeaderFields)
        hasher.combine(request.httpBody)
        hasher.combine(request.httpMethod)
    }
    
    static func == (lhs: NetworkRequest, rhs: NetworkRequest) -> Bool {
        let lhsRequest = lhs.request
        let rhsRequest = rhs.request
        return lhsRequest.allHTTPHeaderFields == rhsRequest.allHTTPHeaderFields
            && lhsRequest.url == rhsRequest.url && lhsRequest.httpBody == rhsRequest.httpBody
            && lhsRequest.httpMethod == rhsRequest.httpMethod
    }
    
    static func =~ (lhs: NetworkRequest, rhs: URLRequest) -> Bool {
        let lhsRequest = lhs.request
        return lhsRequest.allHTTPHeaderFields == rhs.allHTTPHeaderFields
            && lhsRequest.url == rhs.url && lhsRequest.httpBody == rhs.httpBody
            && lhsRequest.httpMethod == rhs.httpMethod
    }
    
}
