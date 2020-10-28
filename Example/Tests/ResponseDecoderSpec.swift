//
//  ResponseDecoderSpec.swift
//  iONess_Tests
//
//  Created by Nayanda Haberty (ID) on 27/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import iONess

class ResponseDecoderSpec: QuickSpec {
    override func spec() {
        describe("positive case") {
            it("should decode json from data") {
                let mock = JSONPlaceholder.mock()
                let data = try! JSONEncoder().encode(mock)
                let decoded = try! JSONDecodableDecoder<JSONPlaceholder>().decode(from: data)
                expect(decoded).to(equal(mock))
            }
            it("should decode json array from data") {
                let mocks: [JSONPlaceholder] = [.mock(), .mock(), .mock(), .mock(), .mock()]
                let data = try! JSONEncoder().encode(mocks)
                let decodeds = try! ArrayJSONDecodableDecoder<JSONPlaceholder>().decode(from: data)
                expect(decodeds).to(equal(mocks))
            }
            it("should decode json from data") {
                let mock = JSONPlaceholder.mock()
                let data = try! JSONEncoder().encode(mock)
                let decoded = try! JSONResponseDecoder().decode(from: data)
                expect(decoded["id"] as? Int).to(equal(mock.id))
                expect(decoded["userId"] as? Int).to(equal(mock.userId))
                expect(decoded["body"] as? String).to(equal(mock.body))
                expect(decoded["completed"] as? Bool).to(equal(mock.completed))
                expect(decoded["title"] as? String).to(equal(mock.title))
            }
            it("should decode json array from data") {
                let mocks: [JSONPlaceholder] = [.mock(), .mock(), .mock(), .mock(), .mock()]
                let data = try! JSONEncoder().encode(mocks)
                let decodeds = try! ArrayJSONResponseDecoder().decode(from: data)
                expect(decodeds.count).to(equal(mocks.count))
                for (index, decoded) in decodeds.enumerated() {
                    guard let dict: [String: Any] = decoded as? [String : Any] else {
                        fail()
                        return
                    }
                    let mock = mocks[index]
                    expect(dict["id"] as? Int).to(equal(mock.id))
                    expect(dict["userId"] as? Int).to(equal(mock.userId))
                    expect(dict["body"] as? String).to(equal(mock.body))
                    expect(dict["completed"] as? Bool).to(equal(mock.completed))
                    expect(dict["title"] as? String).to(equal(mock.title))
                }
            }
            it("should decode json from data") {
                let mock = JSONPlaceholder.mock()
                let data = try! JSONEncoder().encode(mock)
                let decoded = try! PlaceholderJSONDecoder().decode(from: data)
                expect(decoded).to(equal(mock))
            }
            it("should decode json from string") {
                let mock = JSONPlaceholder.mock()
                let data = try! JSONEncoder().encode(mock)
                let decoded = try! PlaceholderStringDecoder().decode(from: data)
                expect(decoded).to(equal(mock))
            }
            it("should decode array json from data") {
                let mocks: [JSONPlaceholder] = [.mock(), .mock(), .mock(), .mock(), .mock()]
                let data = try! JSONEncoder().encode(mocks)
                let decoder = ArrayedJSONDecoder(singleDecoder: PlaceholderJSONDecoder())
                let decodeds = try! decoder.decode(from: data)
                expect(decodeds).to(equal(mocks))
            }
        }
        describe("negative test") {
            it("should fail decode json from data") {
                let mock = RandomJSON()
                let data = try! JSONEncoder().encode(mock)
                expect {
                    let decoded = try JSONDecodableDecoder<JSONPlaceholder>().decode(from: data)
                    return decoded
                }.to(throwError())
            }
            it("should fail decode json array from data") {
                let mocks: [RandomJSON] = [.init(), .init(), .init(), .init(), .init()]
                let data = try! JSONEncoder().encode(mocks)
                expect {
                    let decoded = try ArrayJSONDecodableDecoder<JSONPlaceholder>().decode(from: data)
                    return decoded
                }.to(throwError())
            }
            it("should fail decode json from data") {
                let data = String.random().data(using: .utf8)!
                expect {
                    let decoded = try JSONResponseDecoder().decode(from: data)
                    return decoded
                }.to(throwError())
            }
            it("should fail decode array json from data") {
                let data = String.random().data(using: .utf8)!
                expect {
                    let decoded = try ArrayJSONResponseDecoder().decode(from: data)
                    return decoded
                }.to(throwError())
            }
            it("should fail decode json from data") {
                let data = String.random().data(using: .utf8)!
                expect {
                    let decoded = try PlaceholderJSONDecoder().decode(from: data)
                    return decoded
                }.to(throwError())
            }
            it("should fail decode json from string") {
                let data = String.random().data(using: .utf8)!
                expect {
                    let decoded = try PlaceholderStringDecoder().decode(from: data)
                    return decoded
                }.to(throwError())
            }
            it("should fail decode array json from data") {
                let data = String.random().data(using: .utf8)!
                let decoder = ArrayedJSONDecoder(singleDecoder: PlaceholderJSONDecoder())
                expect {
                    let decodeds = try decoder.decode(from: data)
                    return decodeds
                }.to(throwError())
            }
        }
    }
}

class PlaceholderJSONDecoder: BaseJSONDecoder<JSONPlaceholder> {
    override func decode(from json: [String : Any]) throws -> JSONPlaceholder {
        .init(
            id: json["id"] as? Int ?? -1,
            title: json["title"] as? String ?? "",
            body: json["body"] as? String,
            userId: json["userId"] as? Int,
            completed: json["completed"] as? Bool
        )
    }
}

class PlaceholderStringDecoder: BaseStringDecoder<JSONPlaceholder> {
    override func decode(from json: String) throws -> JSONPlaceholder {
        let data = json.data(using: .utf8)!
        let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return .init(
            id: dict["id"] as? Int ?? -1,
            title: dict["title"] as? String ?? "",
            body: dict["body"] as? String,
            userId: dict["userId"] as? Int,
            completed: dict["completed"] as? Bool
        )
    }
} 
