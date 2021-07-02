//
//  NetworkSessionManager.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public typealias URLCompletion<Param> = (Param?, URLResponse?, Error?) -> Void

extension NetworkSessionManager: LockRunner {
    
    func task(for request: URLRequest) -> URLSessionTask? {
        lockedRun {
            completions.first { $0.key =~ request }?.key.task
        }
    }
    
    func removeAndCancelCompletion(for request: URLRequest) {
        let result = lockedRun {
            completions.first(where: { $0.key =~ request })
        }
        guard let biConsumer = result else {
            return
        }
        lockedRun {
            completions.removeValue(forKey: biConsumer.key)
        }
        biConsumer.value(
            nil,
            nil,
            NetworkSessionError(
                statusCode: NSURLErrorCancelled,
                description: "iONess Error: Cancelled by NetworkSessionManager"
            )
        )
        
    }
    
    func removeAndGetCompletion<Param>(for request: URLRequest) -> URLCompletion<Param>? {
        let result = lockedRun {
            completions.first(where: { $0.key =~ request })
        }
        guard let biConsumer = result else {
            return nil
        }
        lockedRun {
            completions.removeValue(forKey: biConsumer.key)
        }
        return { biConsumer.value($0, $1, $2) }
        
    }
    
    func currentCompletion<Param>(for request: URLRequest) ->  URLCompletion<Param>? {
        lockedRun {
            guard let completion = completions.first(where: { $0.key =~ request })?.value else {
                return nil
            }
            return { completion($0, $1, $2) }
        }
    }
    
    func assign<Param>(for request: URLRequest, completion: @escaping URLCompletion<Param>) {
        lockedRun {
            guard let key = completions.first(where: { $0.key =~ request })?.key else { return }
            completions[key] = { completion($0 as? Param, $1, $2) }
        }
    }
    
    func assign<Param>(for request: URLRequest, task: URLSessionTask, completion: @escaping URLCompletion<Param>) {
        lockedRun {
            completions[.init(request: request, task: task)] = { completion($0 as? Param, $1, $2) }
        }
    }
    
    func isRunning(for request: URLRequest) -> Bool {
        lockedRun {
            completions.contains(where: { $0.key =~ request })
        }
    }
    
    func downloadTask(with request: URLRequest, resumeData: Data? = nil, completionHandler: @escaping URLCompletion<URL>) -> URLSessionDownloadTask {
        let updatedRequest = delegate?.ness(self, willRequest: request) ?? request
        defer {
            delegate?.ness(self, didRequest: updatedRequest)
        }
        var completion: URLCompletion<URL> = completionHandler
        if let prevCompletion: URLCompletion<URL> = currentCompletion(for: updatedRequest) {
            let decision = duplicatedHandler.duplicatedDownload(
                request: updatedRequest,
                withPreviousCompletion: prevCompletion,
                currentCompletion: completionHandler
            )
            completion = decide(from: decision, updatedRequest, completionHandler, prevCompletion)
            if let task = task(for: updatedRequest) as? URLSessionDownloadTask {
                assign(for: updatedRequest, completion: completion)
                return task
            }
        }
        let task: URLSessionDownloadTask
        let taskCompletion: (URL?, URLResponse?, Error?) -> Void = { [weak self] url, response, error in
            guard let self = self else {
                completion(url, response, error)
                return
            }
            let currentCompletion: URLCompletion<URL>? = self.removeAndGetCompletion(for: updatedRequest)
            currentCompletion?(url, response, error)
        }
        if let data = resumeData {
            task = session.downloadTask(withResumeData: data, completionHandler: taskCompletion)
        } else {
            task = session.downloadTask(with: request, completionHandler: taskCompletion)
        }
        assign(for: updatedRequest, task: task, completion: completion)
        return task
    }
    
    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping URLCompletion<Data>) -> URLSessionUploadTask {
        let updatedRequest = delegate?.ness(self, willRequest: request) ?? request
        defer {
            delegate?.ness(self, didRequest: updatedRequest)
        }
        var completion: URLCompletion<Data> = completionHandler
        if let prevCompletion: URLCompletion<Data> = currentCompletion(for: updatedRequest) {
            let decision = duplicatedHandler.duplicatedUpload(
                request: updatedRequest,
                withPreviousCompletion: prevCompletion,
                currentCompletion: completionHandler
            )
            completion = decide(from: decision, updatedRequest, completionHandler, prevCompletion)
            if let task = task(for: updatedRequest) as? URLSessionUploadTask {
                assign(for: updatedRequest, completion: completion)
                return task
            }
        }
        let task = session.uploadTask(with: updatedRequest, fromFile: fileURL) { [weak self] data, response, error in
            guard let self = self else {
                completion(data, response, error)
                return
            }
            let currentCompletion: URLCompletion<Data>? = self.removeAndGetCompletion(for: updatedRequest)
            currentCompletion?(data, response, error)
        }
        assign(for: updatedRequest, task: task, completion: completion)
        return task
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping URLCompletion<Data>) -> URLSessionDataTask {
        let updatedRequest = delegate?.ness(self, willRequest: request) ?? request
        defer {
            delegate?.ness(self, didRequest: updatedRequest)
        }
        var completion: URLCompletion<Data> = completionHandler
        if let prevCompletion: URLCompletion<Data> = currentCompletion(for: updatedRequest) {
            let decision = duplicatedHandler.duplicatedData(
                request: updatedRequest,
                withPreviousCompletion: prevCompletion,
                currentCompletion: completionHandler
            )
            completion = decide(from: decision, updatedRequest, completionHandler, prevCompletion)
            if let task = task(for: updatedRequest) as? URLSessionDataTask {
                assign(for: updatedRequest, completion: completion)
                return task
            }
        }
        let task = session.dataTask(with: updatedRequest) { [weak self] data, response, error in
            guard let self = self else {
                completion(data, response, error)
                return
            }
            let currentCompletion: URLCompletion<Data>? = self.removeAndGetCompletion(for: updatedRequest)
            currentCompletion?(data, response, error)
        }
        assign(for: updatedRequest, task: task, completion: completion)
        return task
    }
    
    func decide<Param>(
        from decision: RequestDuplicatedDecision<Param>,
        _ request: URLRequest,
        _ completionHandler: @escaping URLCompletion<Param>,
        _ prevCompletion: @escaping URLCompletion<Param>) -> URLCompletion<Param> {
        switch decision {
        case .dropAndRequestAgain:
            removeAndCancelCompletion(for: request)
            return completionHandler
        case .dropAndRequestAgainWithCompletion(let newCompletion):
            removeAndCancelCompletion(for: request)
            return newCompletion
        case .useBothCompletion:
            return { url, response, error in
                prevCompletion(url, response, error)
                completionHandler(url, response, error)
            }
        case .useCurrentCompletion:
            return completionHandler
        case .ignoreCurrentCompletion:
            return prevCompletion
        case .useCompletion(let newCompletion):
            return newCompletion
        }
    }
}
