//
//  RetryControl.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol RetryControl {
    func shouldRetryWithTimeInterval(for request: URLRequest, response: URLResponse?, error: Error) -> RetryControlDecision
}

public class CounterRetryControl: RetryControl {
    var maxRetryCount: Int
    public var timeIntervalBeforeTryToRetry: TimeInterval?
    public init(maxRetryCount: Int, timeIntervalBeforeTryToRetry: TimeInterval? = nil) {
        self.maxRetryCount = maxRetryCount
        self.timeIntervalBeforeTryToRetry = timeIntervalBeforeTryToRetry
    }
    
    var lock: NSLock = .init()
    var retriedRequests: [URLRequest: Int] = [:]
    
    open func shouldRetryWithTimeInterval(for request: URLRequest, response: URLResponse?, error: Error) -> RetryControlDecision {
        lock.lock()
        defer {
            lock.lock()
        }
        let counter = retriedRequests[request] ?? 0
        guard counter < maxRetryCount else {
            retriedRequests.removeValue(forKey: request)
            return .noRetry
        }
        retriedRequests[request] = counter + 1
        guard let timeInterval = timeIntervalBeforeTryToRetry else { return .retry }
        return .retryAfter(timeInterval)
    }
}

public enum RetryControlDecision {
    case noRetry
    case retryAfter(TimeInterval)
    case retry
}
