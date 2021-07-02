//
//  Resumable.swift
//  iONess
//
//  Created by Nayanda Haberty on 02/07/21.
//

import Foundation

/// Resume Status
public enum ResumeStatus {
    case resumed
    case failToResume
}

/// Resumable protocol
public protocol Resumable {
    /// pause the task
    func pause()
    /// try to resume the task
    func resume() -> ResumeStatus
}

public extension Resumable where Self: RequestPromise, Handler: Resumable {
    
    /// pause the task
    func pause() {
        handler?.pause()
    }
    
    /// try to resume the task
    /// - Returns: Resume status
    func resume() -> ResumeStatus {
        handler?.resume() ?? .failToResume
    }
}
