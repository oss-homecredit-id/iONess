//
//  IntegratedTest.swift
//  iONess_Tests
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import iONess

class IntegratedTestSpec: QuickSpec {
    override func spec() {
        it("should merge two completion") {
            let randomNumber: Int = .random(in: 0..<10)
            var firstResult: URLResult?
            var secondResult: URLResult?
            let request = Ness(onDuplicated: .keepAllCompletion)
                .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/todos/\(randomNumber)")
                .prepareDataRequest()
            request.then { result in
                firstResult = result
            }
            waitUntil(timeout: 15) { done in
                request.then { result in
                    secondResult = result
                    done()
                }
            }
            guard let fResult = firstResult,
                  let sResult = secondResult,
                  let fMessage = fResult.httpMessage,
                  let sMessage = sResult.httpMessage else {
                fail("Fail to get data")
                return
            }
            expect(fResult.isSucceed).to(equal(sResult.isSucceed))
            expect(fMessage.isHaveBody).to(equal(sMessage.isHaveBody))
            expect(fMessage.body).to(equal(sMessage.body))
            expect(fMessage.headers).to(equal(sMessage.headers))
        }
        it("should drop first completion") {
            let randomNumber: Int = .random(in: 10..<20)
            var firstResult: URLResult?
            var secondResult: URLResult?
            let request = Ness(onDuplicated: .dropPreviousRequest)
                .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/todos/\(randomNumber)")
                .prepareDataRequest()
            request.then { result in
                firstResult = result
            }
            waitUntil(timeout: 15) { done in
                request.then { result in
                    secondResult = result
                    done()
                }
            }
            guard let fResult = firstResult,
                  let sResult = secondResult else {
                fail("Fail to get data")
                return
            }
            expect(fResult.isSucceed).to(beFalse())
            expect(sResult.isSucceed).to(beTrue())
        }
        it("should use first completion") {
            let randomNumber: Int = .random(in: 20..<30)
            var firstResult: URLResult?
            let request = Ness(onDuplicated: .keepFirstCompletion)
                .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/todos/\(randomNumber)")
                .prepareDataRequest()
            waitUntil(timeout: 15) { done in
                request.then { result in
                    firstResult = result
                    done()
                }
                request.then { _ in
                    fail("This completion should not be executed")
                    done()
                }
            }
            guard let fResult = firstResult else {
                fail("Fail to get data")
                return
            }
            expect(fResult.isSucceed).to(beTrue())
        }
        it("should use last completion") {
            let randomNumber: Int = .random(in: 30..<40)
            var secondResult: URLResult?
            let request = Ness(onDuplicated: .keepLatestCompletion)
                .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/todos/\(randomNumber)")
                .prepareDataRequest()
            waitUntil(timeout: 15) { done in
                request.then { _ in
                    fail("This completion should not be executed")
                    done()
                }
                request.then { result in
                    secondResult = result
                    done()
                }
            }
            guard let sResult = secondResult else {
                fail("Fail to get data")
                return
            }
            expect(sResult.isSucceed).to(beTrue())
        }
        it("should get json data") {
            let randomNumber: Int = .random(in: 40..<50)
            var requestResult: URLResult?
            waitUntil(timeout: 15) { done in
                Ness.default
                    .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/todos/\(randomNumber)")
                    .prepareDataRequest()
                    .then { result in
                        requestResult = result
                        done()
                    }
            }
            guard let result = requestResult,
                  let message = result.httpMessage else {
                fail("Fail to get data")
                return
            }
            expect(result.error).to(beNil())
            expect(message.isHaveBody).to(beTrue())
            expect(message.headers.isEmpty).toNot(beTrue())
            expect(message.headers["Content-Type"]).to(equal("application/json; charset=utf-8"))
            expect(message.headers["access-control-allow-credentials"]).to(equal("true"))
            guard let json = try? message.parseJSONBody() else {
                fail("Fail to parse data")
                return
            }
            expect(json["userId"] as? Int).to(beGreaterThan(0))
            expect(json["id"] as? Int).to(equal(randomNumber))
            expect(json.keys.contains("title")).to(beTrue())
            expect(json.keys.contains("completed")).to(beTrue())
            expect(json.keys.contains("body")).to(beFalse())
            guard let obj: JSONPlaceholder = try? message.parseJSONBody() else {
                fail("Fail to parse data")
                return
            }
            expect(obj.userId).to(beGreaterThan(0))
            expect(obj.id).to(equal(randomNumber))
            expect(obj.body).to(beNil())
            expect(obj.title.isEmpty).toNot(beTrue())
        }
        it("should get array data") {
            var requestResult: URLResult?
            waitUntil(timeout: 15) { done in
                Ness.default
                    .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/posts")
                    .prepareDataRequest()
                    .then { result in
                        requestResult = result
                        done()
                    }
            }
            guard let result = requestResult,
                  let message = result.httpMessage else {
                fail("Fail to get data")
                return
            }
            expect(result.error).to(beNil())
            expect(message.isHaveBody).to(beTrue())
            expect(message.headers.isEmpty).toNot(beTrue())
            expect(message.headers["Content-Type"]).to(equal("application/json; charset=utf-8"))
            expect(message.headers["access-control-allow-credentials"]).to(equal("true"))
            guard let anyArray = try? message.parseArrayJSONBody(), let array = anyArray as? [[String: Any]] else {
                fail("Fail to parse data")
                return
            }
            for (index, json) in array.enumerated() {
                expect(json["id"] as? Int).to(equal(index + 1))
                expect(json.keys.contains("userId")).to(beTrue())
                expect(json.keys.contains("title")).to(beTrue())
                expect(json.keys.contains("body")).to(beTrue())
                expect(json.keys.contains("completed")).to(beFalse())
            }
            guard let objArray: [JSONPlaceholder] = try? message.parseArrayJSONBody() else {
                fail("Fail to parse data")
                return
            }
            for (index, obj) in objArray.enumerated() {
                expect(obj.userId).toNot(beNil())
                expect(obj.id).to(equal(index + 1))
                expect(obj.body?.isEmpty ?? true).toNot(beTrue())
                expect(obj.title.isEmpty).toNot(beTrue())
            }
        }
        it("should post data") {
            var requestResult: URLResult?
            let randomNumber: Int = .random(in: 0..<10)
            waitUntil(timeout: 15) { done in
                Ness.default
                    .httpRequest(.post, withUrl: "https://jsonplaceholder.typicode.com/posts")
                    .set(jsonEncodable: JSONPlaceholder(title: "foo", body: "bar", userId: randomNumber))
                    .prepareDataRequest()
                    .then { result in
                        requestResult = result
                        done()
                    }
            }
            guard let result = requestResult,
                  let message = result.httpMessage else {
                fail("Fail to get data")
                return
            }
            expect(result.error).to(beNil())
            expect(message.isHaveBody).to(beTrue())
            expect(message.headers.isEmpty).toNot(beTrue())
            expect(message.headers["Content-Type"]).to(equal("application/json; charset=utf-8"))
            expect(message.headers["access-control-allow-credentials"]).to(equal("true"))
            guard let json = try? message.parseJSONBody() else {
                fail("Fail to parse data")
                return
            }
            expect(json["id"] as? Int).toNot(beNil())
            expect(json["userId"] as? Int).to(equal(randomNumber))
            expect(json["title"] as? String).to(equal("foo"))
            expect(json["body"] as? String).to(equal("bar"))
            expect(json.keys.contains("completed")).to(beFalse())
            guard let obj: JSONPlaceholder = try? message.parseJSONBody() else {
                fail("Fail to parse data")
                return
            }
            expect(obj.userId).to(equal(randomNumber))
            expect(obj.title).to(equal("foo"))
            expect(obj.body).to(equal("bar"))
            expect(obj.completed).to(beNil())
        }
        it("should aggregate request") {
            let firstRealUrl: URL = try! "https://jsonplaceholder.typicode.com/todos/\(Int.random(in: 0..<10))".asUrl()
            let secondRealUrl: URL = try! "https://jsonplaceholder.typicode.com/todos/\(Int.random(in: 10..<20))".asUrl()
            let firstRequest = Ness.default
                .httpRequest(.get, withUrl: firstRealUrl)
                .prepareDataRequest()
            let secondRequest = Ness.default
                .httpRequest(.get, withUrl: secondRealUrl)
                .prepareDataRequest()
            var firstResult: URLResult?
            var secondResult: URLResult?
            waitUntil(timeout: 15) { done in
                firstRequest.aggregate(with: secondRequest).then { result in
                    expect(result.areCompleted).to(beTrue())
                    expect(result.results.count).to(equal(2))
                    firstResult = result.results[0]
                    secondResult = result.results[1]
                    done()
                }
            }
            let firstUrl = try! firstResult?.httpMessage?.url.asUrl()
            let secondUrl = try! secondResult?.httpMessage?.url.asUrl()
            expect(firstUrl).toNot(beNil())
            expect(secondUrl).toNot(beNil())
            expect(firstUrl).toNot(equal(secondUrl))
            expect(firstUrl == firstRealUrl || firstUrl == secondRealUrl).to(beTrue())
            expect(secondUrl == firstRealUrl || secondUrl == secondRealUrl).to(beTrue())
        }
    }
}
