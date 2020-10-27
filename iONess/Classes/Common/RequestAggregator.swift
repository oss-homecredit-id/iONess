//
//  RequestAggregator.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public class RequestAggregator<AggregatedThenable: URLThenableRequest>: Thenable {
    public typealias Result = Results<AggregatedThenable.Result>
    public typealias Response = AggregatedThenable.Response
    public typealias DropablePromise = DropableRequestAggregator<AggregatedThenable>
    typealias Wrapper = ThenableWrapper<AggregatedThenable>
    
    var wrappedRequests: [Wrapper] = []
    var results: Result?
    
    public init(requests: [AggregatedThenable]) {
        wrappedRequests.append(
            contentsOf: requests.compactMap {
                .init(promise: $0, completion: nil)
            }
        )
    }
    
    public func aggregate(_ request: AggregatedThenable, withCompletion closure: ((AggregatedThenable.Result) -> Void)? = nil) -> Self {
        wrappedRequests.append(.init(promise: request, completion: closure))
        return self
    }
    
    public func aggregate(all requests: [AggregatedThenable]) -> Self{
        wrappedRequests.append(contentsOf: requests.compactMap { .init(promise: $0, completion: nil)})
        return self
    }
    
    @discardableResult
    public func then(run closure: @escaping (Result) -> Void, whenFailed failClosure: @escaping (Result) -> Void) -> DropablePromise {
        return then { result in
            guard !result.isFailed else {
                failClosure(result)
                return
            }
            closure(result)
        }
    }
    
    @discardableResult
    public func then(run closure: @escaping (Result) -> Void) -> DropablePromise {
        let retainedRequest = DropablePromise.RunningRequests(targetRunCount: wrappedRequests.count)
        let retainedResults = Result(targetCompletedCount: wrappedRequests.count)
        for thenable in wrappedRequests {
            let promise = thenable.promise
            let completion = thenable.completion
            retainedRequest.add(
                promise.then { result in
                    retainedResults.add(result: result)
                    if result.isFailed {
                        retainedRequest.cancel()
                        closure(retainedResults)
                    } else if retainedResults.areCompleted {
                        closure(retainedResults)
                    }
                    completion?(result)
                }
            )
        }
        return .init(runningRequests: retainedRequest, results: retainedResults)
    }
}

extension RequestAggregator {
    
    public class Results<AggregatedResult: NetworkResult>: LockRunner {
        let lock = NSLock()
        public var results: [AggregatedResult] = []
        public var isFailed: Bool {
            lockedRun {
                results.contains { $0.error != nil }
            }
        }
        public var areCompleted: Bool {
            lockedRun {
                results.count == targetCompletedCount
                    && !results.contains { $0.error != nil }
            }
        }
        var targetCompletedCount: Int
        
        init(targetCompletedCount: Int) {
            self.targetCompletedCount = targetCompletedCount
        }
        
        func add(result: AggregatedResult) {
            lockedRun {
                results.append(result)
            }
        }
    }
}

public class DropableRequestAggregator<AggregatedThenable: URLThenableRequest>: Dropable {
    public typealias AggregatedResponse = AggregatedThenable.Response
    public typealias Response = Responses<AggregatedResponse>
    public typealias Result = RequestAggregator<AggregatedThenable>.Result
    var runningRequests: RunningRequests
    var results: Result
    
    init(runningRequests: RunningRequests, results: Result) {
        self.runningRequests = runningRequests
        self.results = results
    }
    
    public var status: DropableStatus<Response> {
        if runningRequests.canceled {
            return .dropped
        }
        if results.isFailed {
            return .error(NetworkSessionError(description: "iONess Error: one of more aggregated request are failed"))
        } else if results.areCompleted {
            return .completed(
                .init(
                    responses: runningRequests.runningRequests.compactMap {
                        ($0 as? DropableDataRequest)?.task.response as? AggregatedResponse
                    }
                )
            )
        }
        return .error(
            NetworkSessionError(description: "iONess Error: unknown error")
        )
    }
    
    public func drop() {
        runningRequests.cancel()
    }
}

extension DropableRequestAggregator {
    
    public struct Responses<AggregatedResponse> {
        var responses: [AggregatedResponse] = []
    }
    
    class RunningRequests: LockRunner {
        let lock = NSLock()
        var runningRequests: [DropableURLRequest<AggregatedResponse>] = []
        var canceled: Bool = false
        var targetRunCount: Int
        var isAllRequestRun: Bool {
            lockedRun {
                runningRequests.count == targetRunCount && !canceled
            }
        }
        var progress: Float {
            lockedRun {
                var total: Float = 0
                for dropable in runningRequests {
                    switch dropable.status {
                    case .running(let progress):
                        total += progress
                    case .completed(_):
                        total += 1
                    default:
                        break
                    }
                }
                return total / Float(targetRunCount)
            }
        }
        
        init(targetRunCount: Int) {
            self.targetRunCount = targetRunCount
        }
        
        func add(_ dropable: DropableURLRequest<AggregatedResponse>) {
            if dropable is FailedURLRequest {
                cancel()
                return
            }
            guard !canceled else {
                dropable.drop()
                return
            }
            lockedRun {
                runningRequests.append(dropable)
            }
        }
        
        func cancel() {
            lockedRun {
                canceled = true
                runningRequests.forEach { $0.drop() }
                runningRequests.removeAll()
            }
        }
    }
}

struct ThenableWrapper<Wrapped: Thenable> {
    var promise: Wrapped
    var completion: ((Wrapped.Result) -> Void)?
}
