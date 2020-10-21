//
//  NetworkSessionManager.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public typealias URLCompletion<Param> = (Param?, URLResponse?, Error?) -> Void

public extension NetworkSessionManager {
    
    func task(for request: URLRequest) -> URLSessionTask? {
        lockedRun {
            completions.first { $0.key =~ request }?.key.task
        }
    }
    
    func removeAndCancelCompletion(for request: URLRequest) {
        lockedRun {
            guard let biConsumer = completions.first(where: { $0.key =~ request }) else {
                return
            }
            completions.removeValue(forKey: biConsumer.key)
            biConsumer.value(
                nil,
                nil,
                NetworkSessionError(description: "iONess Error: Cancelled by NetworkSessionManager")
            )
        }
    }
    
    func removeAndGetCompletion<Param>(for request: URLRequest) -> URLCompletion<Param>? {
        lockedRun {
            guard let biConsumer = completions.first(where: { $0.key =~ request }) else {
                return nil
            }
            completions.removeValue(forKey: biConsumer.key)
            return { biConsumer.value($0, $1, $2) }
        }
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
    
    func lockedRun<Result>(_ runner: () -> Result) -> Result {
        lock.lock()
        defer {
            lock.unlock()
        }
        return runner()
    }
    
    func downloadTask(with request: URLRequest, completionHandler: @escaping URLCompletion<URL>) -> URLSessionDownloadTask {
        var completion: URLCompletion<URL> = completionHandler
        if let prevCompletion: URLCompletion<URL> = currentCompletion(for: request) {
            let decision = duplicatedHandler.duplicatedDownload(
                request: request,
                withPreviousCompletion: prevCompletion,
                currentCompletion: completionHandler
            )
            completion = decide(from: decision, request, completionHandler, prevCompletion)
            if let task = task(for: request) as? URLSessionDownloadTask {
                assign(for: request, completion: completion)
                return task
            }
        }
        let task = session.downloadTask(with: request) { [weak self] url, response, error in
            guard let self = self else {
                completion(url, response, error)
                return
            }
            let currentCompletion: URLCompletion<URL>? = self.removeAndGetCompletion(for: request)
            currentCompletion?(url, response, error)
        }
        assign(for: request, task: task, completion: completion)
        task.resume()
        return task
    }
    
    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        var completion: URLCompletion<Data> = completionHandler
        if let prevCompletion: URLCompletion<Data> = currentCompletion(for: request) {
            let decision = duplicatedHandler.duplicatedUpload(
                request: request,
                withPreviousCompletion: prevCompletion,
                currentCompletion: completionHandler
            )
            completion = decide(from: decision, request, completionHandler, prevCompletion)
            if let task = task(for: request) as? URLSessionUploadTask {
                assign(for: request, completion: completion)
                return task
            }
        }
        let task = session.uploadTask(with: request, fromFile: fileURL) { [weak self] data, response, error in
            guard let self = self else {
                completion(data, response, error)
                return
            }
            let currentCompletion: URLCompletion<Data>? = self.removeAndGetCompletion(for: request)
            currentCompletion?(data, response, error)
        }
        assign(for: request, task: task, completion: completion)
        task.resume()
        return task
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        var completion: URLCompletion<Data> = completionHandler
        if let prevCompletion: URLCompletion<Data> = currentCompletion(for: request) {
            let decision = duplicatedHandler.duplicatedData(
                request: request,
                withPreviousCompletion: prevCompletion,
                currentCompletion: completionHandler
            )
            completion = decide(from: decision, request, completionHandler, prevCompletion)
            if let task = task(for: request) as? URLSessionDataTask {
                assign(for: request, completion: completion)
                return task
            }
        }
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                completion(data, response, error)
                return
            }
            let currentCompletion: URLCompletion<Data>? = self.removeAndGetCompletion(for: request)
            currentCompletion?(data, response, error)
        }
        assign(for: request, task: task, completion: completion)
        task.resume()
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
