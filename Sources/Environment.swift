//
//  Environment.swift
//  SwiftDotenv
//
//  Created by Brendan Conron on 10/17/21.
//

import Collections
import Foundation

/// Environment object that represents a `.env` configuration file.
@dynamicMemberLookup
public struct Environment {
    
    // MARK: - Types
    
    /// Type-safe representation of the value types in a `.env` file.
    public enum Value: Equatable {
        /// Reprensents a boolean value, `true`, or `false`.
        case boolean(Bool)
        /// Represents any double literal.
        case double(Double)
        /// Represents any integer literal.
        case integer(Int)
        /// Represents any string literal.
        case string(String)
        
        /// Convert a value to its string representation.
        public var stringValue: String {
            switch self {
            case let .boolean(value):
                return String(describing: value)
            case let .double(value):
                return String(describing: value)
            case let .integer(value):
                return String(describing: value)
            case let .string(value):
                return value
            }
        }
        
        /// Create a value from a string value.
        /// - Parameter stringValue: String value.
        init(_ stringValue: String) {
            // order of operations is important, double should get checked before integer
            // because integer's downcasting is more permissive
            if let boolValue = Bool(stringValue) {
                self = .boolean(boolValue)
            // enforcing exclusion on the double conversion
            } else if let doubleValue = Double(stringValue), Int(stringValue) == nil {
                self = .double(doubleValue)
            } else if let integerValue = Int(stringValue) {
                self = .integer(integerValue)
            } else {
                self = .string(stringValue)
            }
        }
        
        // MARK: - Equatable
        
        public static func == (lhs: Value, rhs: Value) -> Bool {
            switch (lhs, rhs) {
            case let (.boolean(a), .boolean(b)):
                return a == b
            case let (.double(a), .double(b)):
                return a == b
            case let (.integer(a), .integer(b)):
                return a == b
            case let (.string(a), .string(b)):
                return a == b
            default:
                return false
            }
        }
    }
    
    // MARK: - Errors
    
    /// Represents errors that can occur during encoding.
    public enum DecodingFailure: Error {
        // the key value pair is in some way malformed
        case malformedKeyValuePair
        /// Either the key or value is empty.
        case emptyKeyValuePair(pair: (String, String))
    }
    
    // MARK: - Configuration
    
    /// Delimeter for key value pairs, defaults to `=`.
    public static var delimeter: Character = "="
    
    // MARK: - Private
    
    /// Backing environment values.
    private let values: OrderedDictionary<String, Value>
    
    // MARK: - Initialization
    
    /// Create an environment from a dictionary of keys and values.
    /// - Parameter values: Dictionary of keys and values to seed the environment with.
    /// - Throws: If any key value pair is malformed or empty.
    public init(values: OrderedDictionary<String, String>) throws {
        let transformedValues: OrderedDictionary<String, Value> = try values
            .reduce(into: OrderedDictionary<String, Value>.init()) { accumulated, current in
                // remove invalid values from
                guard !current.key.isEmpty && !current.value.isEmpty else {
                    throw DecodingFailure.emptyKeyValuePair(pair: current)
                }
                accumulated[current.key] = Value(current.value)
            }
        try self.init(values: transformedValues)
    }
    
    /// Create an environment from a dictionary of keys and values.
    /// - Parameter values: Dictionary of keys and values to seed the environment with.
    /// - Throws: If any key value pair is malformed or empty.
    public init(values: OrderedDictionary<String, Value>) throws {
        self.values = try values
            .filter {
                guard case let .string(value) = $0.value else {
                    return true
                }
                guard !value.isEmpty && !$0.key.isEmpty else {
                    throw DecodingFailure.emptyKeyValuePair(pair: ($0.key, value))
                }
                return true
            }
    }
    
    /// Create an environment from the contents of a file.
    /// - Parameter contents: File contents.
    init(contents: String) throws {
        let lines = contents.split(separator: "\n")
        // we loop over all the entries in the file which are already separated by a newline
        var values: OrderedDictionary<String, Value> = .init()
        for line in lines {
            // split by the delimeter
            let substrings = line.split(separator: Self.delimeter)
            // make sure we can grab two and only two string values
            guard
                let key = substrings.first,
                let value = substrings.last,
                substrings.count == 2,
                !key.isEmpty,
                !value.isEmpty else {
                    throw DecodingFailure.malformedKeyValuePair
            }
            // add the results to our values
            values[String(key)] = Value(String(value))
        }
        self.values = values
    }
    
    // MARK: - Serialization
    
    /// Transform the environment into a string representation that can be written to disk.
    /// - Returns: File contents.
    func serialize() throws -> String {
        values.enumerated().reduce(into: "") { accumulated, current in
            accumulated += "\(current.element.key)\(Self.delimeter)\(current.element.value.stringValue)\n"
        }
    }
    
    // MARK: - Subscript
    
    public subscript(key: String) -> Value? {
        extractValue(forKey: key)
    }
    
    public subscript(key: String, default defaultValue: @autoclosure () -> Value) -> Value {
        values[key, default: defaultValue()]
    }
    
    // MARK: Dynamic Member Lookup
    
    public subscript(dynamicMember member: String) -> Value? {
        extractValue(forKey: member)
    }
    
    // MARK: - Helpers
    
    private func extractValue(forKey key: String) -> Value? {
        if let value = values[key] {
            return value
        }
        // otherwise fallback to use `ProcessInfo`
        return Value(ProcessInfo.processInfo.environment[key] ?? "")
    }
}
