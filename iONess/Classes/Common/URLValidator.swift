//
//  URLValidator.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

public protocol URLValidator {
    func validate(for response: URLResponse) -> URLValidatorResult
}

public enum URLValidatorResult: Equatable {
    case valid
    case invalid
    case invalidWithReason(String)
}

public extension URLValidator {
    func combine(with validator: URLValidator) -> URLValidator {
        CombinedURLValidator(validator: self, combined: validator)
    }
}

class CombinedURLValidator: URLValidator {
    
    var validator: URLValidator
    var combined: URLValidator
    
    init(validator: URLValidator, combined: URLValidator) {
        self.validator = validator
        self.combined = combined
    }
    
    func validate(for response: URLResponse) -> URLValidatorResult {
        let result = validator.validate(for: response)
        if result == .valid {
            return combined.validate(for: response)
        }
        return result
    }
}
