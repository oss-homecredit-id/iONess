//
//  HTTPValidator.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol HTTPValidator: URLValidator {
    func validate(forHttp response: HTTPURLResponse) -> URLValidatorResult
}

public extension HTTPValidator {
    func validate(for response: URLResponse) -> URLValidatorResult {
        guard let response = response as? HTTPURLResponse else {
            return .invalidWithReason("iONess Error: Response is not HTTPURLResponse")
        }
        return validate(forHttp: response)
    }
}

public class StatusCodeValidator: HTTPValidator {
    public static var `default`: StatusCodeValidator = .init(200..<300)
    let validRange: Range<Int>
    
    public init(_ validRange: Range<Int>) {
        self.validRange = validRange
    }
    
    public func validate(forHttp response: HTTPURLResponse) -> URLValidatorResult {
        let statusCode = response.statusCode
        guard validRange.contains(statusCode) else {
            return .invalidWithReason("iONess Error: failed with response \(statusCode)")
        }
        return .valid
    }
}

public class HeaderValidator: HTTPValidator {
    let validHeader: [String: String]
    
    public init(_ validHeader: [String: String]) {
        self.validHeader = validHeader
    }
    
    public func validate(forHttp response: HTTPURLResponse) -> URLValidatorResult {
        guard let headers = response.allHeaderFields as? [String: String] else {
            return .invalidWithReason("iONess Error: failed because response have no header")
        }
        for (key, value) in validHeader where headers[key] != value {
            return .invalidWithReason(
                """
                iONess Error: failed because response header for key "\(key)" contains "\(headers[key] ?? "null")", expected "\(value)"
                """
            )
        }
        return .valid
    }
}
