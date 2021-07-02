//
//  RetryControl.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Retry control decision
public enum RetryControlDecision {
    case noRetry
    case retryAfter(TimeInterval)
    case retry
}

/// Retry control protocol
public protocol RetryControl {
    /// Decide request shoudl retry or not
    /// - Parameters:
    ///   - request: request that failed
    ///   - response: response of request
    ///   - error: error occurs on request
    ///   - didHaveDecision: closure to capture the decision
    func shouldRetry(
        for request: URLRequest,
        response: URLResponse?,
        error: Error,
        didHaveDecision: @escaping (RetryControlDecision) -> Void) -> Void
}

/// Retry control based on time request retried
public final class CounterRetryControl: RetryControl, LockRunner {
    
    var maxRetryCount: Int
    /// time interval before do a retry
    public var timeIntervalBeforeTryToRetry: TimeInterval?
    /// Default init
    /// - Parameters:
    ///   - maxRetryCount: maximum retry count
    ///   - timeIntervalBeforeTryToRetry: time interval before do a retry
    public init(maxRetryCount: Int, timeIntervalBeforeTryToRetry: TimeInterval? = nil) {
        self.maxRetryCount = maxRetryCount
        self.timeIntervalBeforeTryToRetry = timeIntervalBeforeTryToRetry
    }
    
    let lock: NSLock = .init()
    var retriedRequests: [URLRequest: Int] = [:]
    
    /// Decide request shoudl retry or not. It will always retry until retry count is match with maxRetryCount
    /// - Parameters:
    ///   - request: request that failed
    ///   - response: response of request
    ///   - error: error occurs on request
    ///   - didHaveDecision: closure to capture the decision
    public func shouldRetry(for request: URLRequest, response: URLResponse?, error: Error, didHaveDecision: @escaping (RetryControlDecision) -> Void) {
        let counter = lockedRun {
            retriedRequests[request] ?? 0
        }
        guard counter < maxRetryCount else {
            lockedRun {
                retriedRequests.removeValue(forKey: request)
            }
            didHaveDecision(.noRetry)
            return
        }
        lockedRun {
            retriedRequests[request] = counter + 1
        }
        guard let timeInterval = timeIntervalBeforeTryToRetry else {
            didHaveDecision(.retry)
            return
        }
        didHaveDecision(.retryAfter(timeInterval))
    }
    
}
