//
//  HTTPValidator.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// HTTP Request Validator
public protocol HTTPValidator: ResponseValidator {
    /// Perform validation for HTTPURLResponse
    /// - Parameter response: The response to validate
    func validate(forHttp response: HTTPURLResponse) -> ResponseValidatorResult
}

public extension HTTPValidator {
    /// Perform validation for HTTPURLResponse
    /// - Parameter response: The response to validate
    /// - Returns: Result of validation
    func validate(for response: URLResponse) -> ResponseValidatorResult {
        guard let response = response as? HTTPURLResponse else {
            return .invalidWithReason("iONess Error: Response is not HTTPURLResponse")
        }
        return validate(forHttp: response)
    }
}

/// HTTP status code validator
public final class StatusCodeValidator: HTTPValidator {
    /// Default validator, will validate is the status code between 200 and 300
    public static var `default`: StatusCodeValidator = .init(200..<300)
    let validRange: Range<Int>
    
    /// Default initializer
    /// - Parameter validRange: range of status code that valid
    public init(_ validRange: Range<Int>) {
        self.validRange = validRange
    }
    
    /// Perform validation for HTTPURLResponse status code
    /// - Parameter response: The response to validate
    /// - Returns: Result of validation
    public func validate(forHttp response: HTTPURLResponse) -> ResponseValidatorResult {
        let statusCode = response.statusCode
        guard validRange.contains(statusCode) else {
            return .invalidWithReason("iONess Error: failed with response \(statusCode)")
        }
        return .valid
    }
}

/// HTTP header validator
public final class HeaderValidator: HTTPValidator {
    let headerToMatch: [String: String]
    let validation: Validation
    
    /// Default initializer
    /// - Parameter validation: type of validation
    /// - Parameter header: header to match
    public init(_ validation: Validation = .shouldMatch, _ header: [String: String]) {
        self.validation = validation
        self.headerToMatch = header
    }
    
    /// Perform validation for HTTPURLResponse header
    /// - Parameter response: The response to validate
    /// - Returns: Result of validation
    public func validate(forHttp response: HTTPURLResponse) -> ResponseValidatorResult {
        let headers = response.allHeaderFields as? [String: String] ?? [:]
        switch validation {
        case .shouldContains:
            guard headers.count >= headerToMatch.count else {
                return .invalidWithReason("iONess header invalid: header size too small")
            }
            return match(headers: headers)
        case .shouldMatch:
            guard headers.count == headerToMatch.count else {
                return .invalidWithReason("iONess header invalid: header size did not match")
            }
            return match(headers: headers)
        case .shouldNotContains:
            return notMatch(headers)
        }
    }
    
    func match(headers: [String : String]) -> ResponseValidatorResult {
        for (key, value) in headerToMatch {
            guard let headerValue = headers[key] else {
                return .invalidWithReason("iONess header invalid: header did not have \"\(key)\" key")
            }
            guard headerValue == value else {
                return .invalidWithReason(
                    "iONess header invalid: header value of \"\(key)\" key did not match (expected: \"\(value)\", got \"\(headerValue)\")"
                )
            }
        }
        return .valid
    }
    
    func notMatch(_ headers: [String : String]) -> ResponseValidatorResult {
        for (key, value) in headerToMatch {
            guard let headerValue = headers[key], headerValue == value else {
                return .invalidWithReason("iONess header invalid: headers contains \"\(key)\" key and \"\(value)\" value")
            }
        }
        return .valid
    }
    
    public enum Validation {
        case shouldMatch
        case shouldContains
        case shouldNotContains
    }
}
