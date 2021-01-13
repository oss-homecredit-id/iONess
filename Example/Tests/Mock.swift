//
//  Mock.swift
//  iONess_Tests
//
//  Created by Nayanda Haberty (ID) on 27/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct JSONPlaceholder: Codable, Equatable {
    var id: Int = 0
    var title: String
    var body: String?
    var userId: Int?
    var completed: Bool? = nil
    
    static func mock() -> JSONPlaceholder {
        .init(
            id: .random(in: 0..<100),
            title: .random(length: .random(in: 10..<100)),
            body: .random(length: .random(in: 10..<100)),
            userId: .random(in: 0..<100),
            completed: .random()
        )
    }
    
    static var `default`: JSONPlaceholder {
        .init(
            id: -1,
            title: "",
            body: nil,
            userId: nil,
            completed: nil
        )
    }
}

struct RandomJSON: Codable {
    var randomInt: Int = .random(in: 0..<100)
    var randomString: String = .random(length: .random(in: 10..<100))
    var randomBool: Bool = .random()
}

extension String {
    public static func random(length: Int = 9) -> String {
        let letters : NSString = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

class SpyObserver<Result> {
    var invokedTime: Int = 0
    let invoked: (Result) -> Void
    init(_ invoked: @escaping (Result) -> Void) {
        self.invoked = invoked
    }
    func invoke(with result: Result) {
        invokedTime += 1
        invoked(result)
    }
}
