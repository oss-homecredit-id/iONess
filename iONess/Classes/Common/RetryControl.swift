//
//  RetryControl.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol RetryControl {
    func shouldRetry(for request: URLRequest, response: URLResponse?, error: Error, didHaveDecision: @escaping (RetryControlDecision) -> Void) -> Void
}

public class CounterRetryControl: RetryControl, LockRunner {
    
    var maxRetryCount: Int
    public var timeIntervalBeforeTryToRetry: TimeInterval?
    public init(maxRetryCount: Int, timeIntervalBeforeTryToRetry: TimeInterval? = nil) {
        self.maxRetryCount = maxRetryCount
        self.timeIntervalBeforeTryToRetry = timeIntervalBeforeTryToRetry
    }
    
    let lock: NSLock = .init()
    var retriedRequests: [URLRequest: Int] = [:]
    
    public func shouldRetry(for request: URLRequest, response: URLResponse?, error: Error, didHaveDecision: @escaping (RetryControlDecision) -> Void) {
        lockedRun {
            let counter = retriedRequests[request] ?? 0
            guard counter < maxRetryCount else {
                retriedRequests.removeValue(forKey: request)
                didHaveDecision(.noRetry)
                return
            }
            retriedRequests[request] = counter + 1
            guard let timeInterval = timeIntervalBeforeTryToRetry else {
                didHaveDecision(.retry)
                return
            }
            didHaveDecision(.retryAfter(timeInterval))
        }
    }
    
}

public enum RetryControlDecision {
    case noRetry
    case retryAfter(TimeInterval)
    case retry
}
