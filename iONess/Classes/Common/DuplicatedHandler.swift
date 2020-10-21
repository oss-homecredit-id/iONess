//
//  DuplicateRequestHandler.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol DuplicatedHandler {
    func duplicatedDownload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<URL>, currentCompletion: @escaping URLCompletion<URL>) -> RequestDuplicatedDecision<URL>
    func duplicatedUpload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data>
    func duplicatedData(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data>
}

public enum RequestDuplicatedDecision<Param> {
    case dropAndRequestAgain
    case dropAndRequestAgainWithCompletion((Param?, URLResponse?, Error?) -> Void)
    case ignoreCurrentCompletion
    case useCurrentCompletion
    case useBothCompletion
    case useCompletion((Param?, URLResponse?, Error?) -> Void)
}

public class DefaultDuplicatedHandler: DuplicatedHandler {
    
    public static var dropPreviousRequest: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .dropAndRequestAgain,
        duplicatedUploadDecision: .dropAndRequestAgain,
        duplicatedDataDecision: .dropAndRequestAgain
    )
    
    public static var keepAllCompletion: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .useBothCompletion,
        duplicatedUploadDecision: .useBothCompletion,
        duplicatedDataDecision: .useBothCompletion
    )
    
    public static var keepFirstCompletion: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .ignoreCurrentCompletion,
        duplicatedUploadDecision: .ignoreCurrentCompletion,
        duplicatedDataDecision: .ignoreCurrentCompletion
    )
    
    public static var keepLatestCompletion: DefaultDuplicatedHandler = .init(
        duplicatedDownloadDecision: .useCurrentCompletion,
        duplicatedUploadDecision: .useCurrentCompletion,
        duplicatedDataDecision: .useCurrentCompletion
    )
    
    var duplicatedDownloadDecision: RequestDuplicatedDecision<URL>
    var duplicatedUploadDecision: RequestDuplicatedDecision<Data>
    var duplicatedDataDecision: RequestDuplicatedDecision<Data>
    
    public init(
        duplicatedDownloadDecision: RequestDuplicatedDecision<URL>,
        duplicatedUploadDecision: RequestDuplicatedDecision<Data>,
        duplicatedDataDecision: RequestDuplicatedDecision<Data>) {
        self.duplicatedDownloadDecision = duplicatedDownloadDecision
        self.duplicatedUploadDecision = duplicatedUploadDecision
        self.duplicatedDataDecision = duplicatedDataDecision
    }
    
    public func duplicatedDownload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<URL>, currentCompletion: @escaping URLCompletion<URL>) -> RequestDuplicatedDecision<URL> {
        duplicatedDownloadDecision
    }
    
    public func duplicatedUpload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data> {
        duplicatedUploadDecision
    }
    
    public func duplicatedData(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data> {
        duplicatedDataDecision
    }
    
    
}
