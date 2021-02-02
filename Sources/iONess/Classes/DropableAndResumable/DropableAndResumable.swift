//
//  DropableAndResumable.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol Dropable {
    associatedtype Response
    var status: DropableStatus<Response> { get }
    func drop()
}

public enum DropableStatus<Response> {
    case running(Float)
    case dropped
    case idle
    case completed(Response)
    case error(Error)
}

extension Optional: Dropable where Wrapped: Dropable {
    public typealias Response = Wrapped.Response
    
    public var status: DropableStatus<Response> {
        self?.status ?? .idle
    }
    
    public func drop() {
        guard let wrapped = self else { return }
        wrapped.drop()
    }
}

public protocol Resumable {
    func pause()
    func resume() -> ResumeStatus
}

public enum ResumeStatus {
    case resumed
    case failToResume
}
