//
//  DuplicateRequestHandler.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Duplicated Handler protocol
public protocol DuplicatedHandler {
    /// Decide what to do when identical download request is occurs at the same time
    /// - Parameters:
    ///   - request: Duplicated request
    ///   - previousCompletion: Previous completion
    ///   - currentCompletion: Current completion
    func duplicatedDownload(
        request: URLRequest,
        withPreviousCompletion previousCompletion: @escaping URLCompletion<URL>,
        currentCompletion: @escaping URLCompletion<URL>) -> RequestDuplicatedDecision<URL>
    /// Decide what to do when identical upload request is occurs at the same time
    /// - Parameters:
    ///   - request: Duplicated request
    ///   - previousCompletion: Previous completion
    ///   - currentCompletion: Current completion
    func duplicatedUpload(
        request: URLRequest,
        withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>,
        currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data>
    /// Decide what to do when identical data request is occurs at the same time
    /// - Parameters:
    ///   - request: Duplicated request
    ///   - previousCompletion: Previous completion
    ///   - currentCompletion: Current completion
    func duplicatedData(
        request: URLRequest,
        withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>,
        currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data>
}

/// Duplicated decision
public enum RequestDuplicatedDecision<Param> {
    case dropAndRequestAgain
    case dropAndRequestAgainWithCompletion((Param?, URLResponse?, Error?) -> Void)
    case ignoreCurrentCompletion
    case useCurrentCompletion
    case useBothCompletion
    case useCompletion((Param?, URLResponse?, Error?) -> Void)
}

/// Default Duplicated handler
public final class DefaultDuplicatedHandler: DuplicatedHandler {
    
    /// Default drop previous request
    public static var dropPreviousRequest: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .dropAndRequestAgain,
        duplicatedUploadDecision: .dropAndRequestAgain,
        duplicatedDataDecision: .dropAndRequestAgain
    )
    
    /// Default keep all completion and not creating a new request
    public static var keepAllCompletion: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .useBothCompletion,
        duplicatedUploadDecision: .useBothCompletion,
        duplicatedDataDecision: .useBothCompletion
    )
    
    /// Ignore latest completion
    public static var useFirstCompletion: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .ignoreCurrentCompletion,
        duplicatedUploadDecision: .ignoreCurrentCompletion,
        duplicatedDataDecision: .ignoreCurrentCompletion
    )
    
    /// Use latest completion
    public static var useLatestCompletion: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .useCurrentCompletion,
        duplicatedUploadDecision: .useCurrentCompletion,
        duplicatedDataDecision: .useCurrentCompletion
    )
    
    var duplicatedDownloadDecision: RequestDuplicatedDecision<URL>
    var duplicatedUploadDecision: RequestDuplicatedDecision<Data>
    var duplicatedDataDecision: RequestDuplicatedDecision<Data>
    
    init(
        duplicatedDownloadDecision: RequestDuplicatedDecision<URL>,
        duplicatedUploadDecision: RequestDuplicatedDecision<Data>,
        duplicatedDataDecision: RequestDuplicatedDecision<Data>) {
        self.duplicatedDownloadDecision = duplicatedDownloadDecision
        self.duplicatedUploadDecision = duplicatedUploadDecision
        self.duplicatedDataDecision = duplicatedDataDecision
    }
    
    /// Decide what to do when identical download request is occurs at the same time
    /// - Parameters:
    ///   - request: Duplicated request
    ///   - previousCompletion: Previous completion
    ///   - currentCompletion: Current completion
    /// - Returns: decision
    public func duplicatedDownload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<URL>, currentCompletion: @escaping URLCompletion<URL>) -> RequestDuplicatedDecision<URL> {
        duplicatedDownloadDecision
    }
    
    /// Decide what to do when identical upload request is occurs at the same time
    /// - Parameters:
    ///   - request: Duplicated request
    ///   - previousCompletion: Previous completion
    ///   - currentCompletion: Current completion
    /// - Returns: decision
    public func duplicatedUpload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data> {
        duplicatedUploadDecision
    }
    
    /// Decide what to do when identical data request is occurs at the same time
    /// - Parameters:
    ///   - request: Duplicated request
    ///   - previousCompletion: Previous completion
    ///   - currentCompletion: Current completion
    /// - Returns: decision
    public func duplicatedData(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data> {
        duplicatedDataDecision
    }
    
    
}
