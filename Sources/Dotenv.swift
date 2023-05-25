import Darwin
import Foundation

/// Structure used to load and save environment files.
@dynamicMemberLookup
public enum Dotenv {

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
        init?(_ stringValue: String?) {
            guard let stringValue else {
                return nil
            }
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
                // replace escape double quotes
                self = .string(stringValue.trimmingCharacters(in: .init(charactersIn: "\"")).replacingOccurrences(of: "\\\"", with: "\""))
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

    // MARK: Errors
    
    /// Failures that can occur during loading an environment.
    public enum LoadingFailure: Error {
        /// The environment file is not at the path given.
        case environmentFileIsMissing
        /// The environment ifle is in some way malformed.
        case unableToReadEnvironmentFile
        /// Unable to open the environment file, may be a permissions issue.
        case cannotOpenEnvironmentFile(path: String)
    }
    
    /// Represents errors that can occur during decoding.
    public enum DecodingFailure: Error {
        // the key value pair is in some way malformed
        case malformedKeyValuePair
        /// Either the key or value is empty.
        case emptyKeyValuePair(pair: (String, String))
    }
    
    /// Holds common constant values so that they can be referred to by a common name rather than using raw values.
    /// Structure is public because it's being used as the default value for public function arguments.
    public enum Constants {
        
        /// Character that indicates that the line is a line of comments and should be ignored.
        public static let comments = "#"
        
        /// Default file extension for an environment file.
        public static let defaultFileExtension = ".env"
        
        /// Standard newline character.
        public static let newline: Character = "\n"
    }

    // MARK: - Configuration

    /// `FileManager` instance used to load and save configuration files. Can be replaced with a custom instance.
    public static var fileManager = FileManager.default

    /// Delimeter for key value pairs, defaults to `=`.
    public static var delimeter: Character = "="

    /// Process info instance.
    public static var processInfo: ProcessInfo = ProcessInfo.processInfo

    /// Configure the environment with environment values loaded from the environment file.
    /// - Parameters:
    ///   - path: Path for the environment file, defaults to `.env`.
    ///   - overwrite: Flag that indicates if pre-existing values in the environment should be overwritten with values from the environment file, defaults to `true`.
    public static func configure(atPath path: String = Constants.defaultFileExtension, overwrite: Bool = true) throws {
        guard Self.fileManager.fileExists(atPath: path) else {
            throw LoadingFailure.environmentFileIsMissing
        }
        // read the file in line by line
        // using a file pointer to read each line in one by one
        // which is more performant for large files
        guard let file = freopen(path, "r", stdin) else {
            throw LoadingFailure.cannotOpenEnvironmentFile(path: URL(fileURLWithPath: path).absoluteString)
        }
        defer {
            // close the file handle when we're done reading
            fclose(file)
        }
        while let line = readLine(strippingNewline: true), !line.starts(with: Constants.comments) {
            let (key, value) = try extractKeyValuePair(fromLine: line, withDelimeter: Self.delimeter)
            setenv(key, value, overwrite ? 1 : 0)
        }
    }
    
    /// Configure the environment with the values loaded from the environment file. This method can be used from an async context.
    /// - Parameters:
    ///   - path: Environment file path, defaults to `.env`.
    ///   - overwrite: Whether or not an existing value should be overwritten, defaults to `true`.
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    public static func configure(atPath path: String = Constants.defaultFileExtension, overwrite: Bool = true) async throws {
        guard Self.fileManager.fileExists(atPath: path) else {
            throw LoadingFailure.environmentFileIsMissing
        }
        let url = URL(fileURLWithPath: path)
        do {
            for try await line in url.lines where !line.starts(with: Constants.comments) {
                let (key, value) = try extractKeyValuePair(fromLine: line, withDelimeter: Self.delimeter)
                setenv(key, value, overwrite ? 1 : 0)
            }
        } catch {
            throw LoadingFailure.unableToReadEnvironmentFile
        }
    }
    
    // MARK: - Helpers
    
    /// Extract a tuple of an environment key value pair from a given line.
    /// - Parameters:
    ///   - line: Line of text.
    ///   - delimeter: Delimeter to separate the text by.
    /// - Returns: Key value tuple pair.
    private static func extractKeyValuePair(fromLine line: String, withDelimeter delimeter: Character = Self.delimeter) throws -> (String, String) {
        let pair = line.split(separator: delimeter)
        guard let key = pair.first, let value = pair.last, pair.count == 2, !key.isEmpty, !value.isEmpty else {
            throw DecodingFailure.malformedKeyValuePair
        }
        return (key.trimmingCharacters(in: .whitespacesAndNewlines), value.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // MARK: - Values

    /// All environment values.
    public static var values: [String: String] {
        processInfo.environment
    }

    // MARK: - Modification

    /// Set a value in the environment.
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key to set the value with.
    ///   - overwrite: Flag that indicates if any existing value should be overwritten, defaults to `true`.
    public static func set(value: Value, forKey key: String, overwrite: Bool = true) {
        set(value: value.stringValue, forKey: key, overwrite: overwrite)
    }

    /// Set a value in the environment.
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key to set the value with.
    ///   - overwrite: Flag that indicates if any existing value should be overwritten, defaults to `true`.
    public static func set(value: String, forKey key: String, overwrite: Bool = true) {
        setenv(key, value, overwrite ? 1 : 0)
    }

    // MARK: - Subscripting

    public static subscript(key: String) -> Value? {
        get {
            Value(values[key])
        } set {
            guard let newValue else { return }
            set(value: newValue, forKey: key)
        }
    }

    public static subscript(key: String, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            Value(values[key]) ?? defaultValue()
        } set {
            set(value: newValue, forKey: key)
        }
    }

    // MARK: Dynamic Member Lookup

    public static subscript(dynamicMember member: String) -> Value? {
        get {
            Value(values[member.camelCaseToSnakeCase().uppercased()])
        } set {
            guard let newValue else { return }
            set(value: newValue, forKey: member.camelCaseToSnakeCase().uppercased())
        }
    }
}
