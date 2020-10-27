//
//  LockRunner.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 27/10/20.
//

import Foundation

protocol LockRunner {
    var lock: NSLock { get }
    func lockedRun<Result>(_ runner: () -> Result) -> Result
}


extension LockRunner {
    func lockedRun<Result>(_ runner: () -> Result) -> Result {
        lock.lock()
        defer {
            lock.unlock()
        }
        return runner()
    }
}
