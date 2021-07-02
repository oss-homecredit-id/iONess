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
import Ergo

class IntegratedTestSpec: QuickSpec {
    override func spec() {
        it("should get json data") {
            let randomNumber: Int = .random(in: 40..<50)
            var requestResult: URLResult?
            waitUntil(timeout: .seconds(15)) { done in
                Ness.default
                    .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/todos/\(randomNumber)")
                    .validate(statusCodes: 200..<300)
                    .dataRequest(with: CounterRetryControl(maxRetryCount: 3))
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
            waitUntil(timeout: .seconds(15)) { done in
                Ness.default
                    .httpRequest(.get, withUrl: "https://jsonplaceholder.typicode.com/posts")
                    .validate(statusCodes: 200..<300)
                    .dataRequest(with: CounterRetryControl(maxRetryCount: 3))
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
            waitUntil(timeout: .seconds(15)) { done in
                Ness.default
                    .httpRequest(.post, withUrl: "https://jsonplaceholder.typicode.com/posts")
                    .set(jsonEncodable: JSONPlaceholder(title: "foo", body: "bar", userId: randomNumber))
                    .validate(statusCodes: 200..<300)
                    .dataRequest(with: CounterRetryControl(maxRetryCount: 3))
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
                .validate(statusCodes: 200..<300)
                .dataRequest(with: CounterRetryControl(maxRetryCount: 3))
            let secondRequest = Ness.default
                .httpRequest(.get, withUrl: secondRealUrl)
                .validate(statusCodes: 200..<300)
                .dataRequest(with: CounterRetryControl(maxRetryCount: 3))
            var firstResult: URLResult?
            var secondResult: URLResult?
            
            waitUntil(timeout: .seconds(15)) { done in
                waitPromises(from: firstRequest, secondRequest).then { result in
                    firstResult = result.0
                    secondResult = result.1
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
