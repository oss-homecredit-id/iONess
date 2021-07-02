//
//  URLValidator.swift
//  iONess
//
//  Created by Nayanda Haberty (ID) on 21/10/20.
//

import Foundation

/// Response Validator
public protocol ResponseValidator {
    /// Validate response to determine is it Error or not
    /// - Parameter response: validation result
    func validate(for response: URLResponse) -> ResponseValidatorResult
}

/// Validation Result
public enum ResponseValidatorResult: Equatable {
    case valid
    case invalid
    case invalidWithReason(String)
}

public extension ResponseValidator {
    /// Combine validator with other validator
    /// - Parameter validator: other response validator
    /// - Returns: Merged ResponseValidator
    func combine(with validator: ResponseValidator) -> ResponseValidator {
        CombinedURLValidator(validator: self, combined: validator)
    }
}

class CombinedURLValidator: ResponseValidator {
    
    var validator: ResponseValidator
    var combined: ResponseValidator
    
    init(validator: ResponseValidator, combined: ResponseValidator) {
        self.validator = validator
        self.combined = combined
    }
    
    func validate(for response: URLResponse) -> ResponseValidatorResult {
        let result = validator.validate(for: response)
        if result == .valid {
            return combined.validate(for: response)
        }
        return result
    }
}
