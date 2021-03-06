//
//  Dotenv.swift
//  SwiftDotenv
//
//  Created by Brendan Conron on 10/17/21.
//

import Foundation

/// Structure used to load and save environment files.
public struct Dotenv {

    // MARK: - Types
    
    /// Failures that can occur during loading an environment.
    public enum LoadingFailure: Error {
        /// The environment file is not at the path given.
        case environmentFileIsMissing
        /// The environment ifle is in some way malformed.
        case unableToReadEnvironmentFile
    }
    
    /// Failures that can occur when saving an environment to disk.
    public enum SavingFailure: Error {
        /// A configuration file already exists at that path.
        case fileAlreadyExists(path: String)
    }

    // MARK: - Configuration

    /// `FileManager` instance used to load and save configuration files. Can be replaced with a custom instance.
    public static var fileManager = FileManager.default

    // MARK: - Loading & Saving
    
    /// Load an environment file.
    /// - Parameter path: Path to load from, defaults to `.env`.
    /// - Returns: Environment object.
    /// - Throws: Any error that occurs during loading.
    public static func load(path: String = ".env") throws -> Environment {
        let fileManager = Self.fileManager
        guard fileManager.fileExists(atPath: path) else {
            throw LoadingFailure.environmentFileIsMissing
        }
        guard let stringData = try? String(contentsOf: URL(fileURLWithPath: path)) else {
            throw LoadingFailure.unableToReadEnvironmentFile
        }
        return try Environment(contents: stringData)
    }
    
    /// Save an environment object to a file.
    /// - Important: This method does not serialize process values to disk.
    /// - Parameters:
    ///   - environment: Environment to serialize.
    ///   - path: Path to save the environment to.
    ///   - force: Flag that indicates if the environment should overwrite an existing file.
    /// - Throws: Any error that occurs during saving such as a file already existing in the specified path.
    public static func save(environment: Environment, toPath path: String, force: Bool = false) throws {
        let contents = try environment.serialize()
        let fileManager = Self.fileManager
        guard !fileManager.fileExists(atPath: path) || force else {
            throw SavingFailure.fileAlreadyExists(path: path)
        }
        fileManager.createFile(atPath: path, contents: contents.data(using: .utf8))
    }
}
