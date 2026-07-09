//
//  DotenvTests.swift
//  SwiftDotenvTests
//
//  Created by Brendan Conron on 10/17/21.
//

#if os(macOS) || os(iOS)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#elseif os(Windows)
import ucrt
#else
#error("Unknown platform")
#endif

import Foundation
import SwiftDotenv
import Testing

#if os(Windows)
/// Shim for POSIX `setenv`, which ucrt doesn't provide; `_putenv_s` always
/// overwrites, so the overwrite flag is honored by checking for an existing
/// value first.
@discardableResult
private func setenv(_ name: String, _ value: String, _ overwrite: Int32) -> Int32 {
    guard overwrite != 0 || ProcessInfo.processInfo.environment[name] == nil else { return 0 }
    return _putenv_s(name, value)
}
#endif

// The environment is process-global state, so the tests must not interleave.
@Suite(.serialized)
struct DotenvTests {

    init() throws {
        let path = try #require(
            Bundle.module.path(forResource: "fixture", ofType: "env"),
            "unable to find env file"
        )
        try Dotenv.configure(atPath: path)
    }

    @Test func configuringEnvironment() {
        #expect(Dotenv.apiKey == .string("some-value"))
        #expect(Dotenv.buildNumber == .integer(5))
        #expect(Dotenv.identifier == .string("com.app.example"))
        #expect(Dotenv.mailTemplate == .string("The \"Quoted\" Title"))
        #expect(Dotenv.dbPassphrase == .string("1qaz?#@\"' wsx$"))
        #expect(Dotenv.nonExistentValue == nil)
    }

    @Test func subscriptingByStrings() {
        // implicitly testing string subscripting
        #expect(Dotenv["API_KEY"] == .string("some-value"))
        #expect(Dotenv["BUILD_NUMBER"] == .integer(5))
        #expect(Dotenv["IDENTIFIER"] == .string("com.app.example"))
    }

    @Test func subscriptingNonexistentValue() {
        #expect(Dotenv.randomVariable == nil)
    }

    @Test func settingValues() {
        Dotenv.set(value: "1234", forKey: "API_KEY")

        #expect(Dotenv.apiKey == .integer(1234))
        #expect(Dotenv.processInfo.environment["API_KEY"] == "1234")
    }

    @Test func overridingValues() {
        setenv("API_KEY", "1234", 1)

        #expect(Dotenv.processInfo.environment["API_KEY"] == "1234")

        Dotenv.set(value: "secret-key", forKey: "API_KEY", overwrite: true)

        #expect(Dotenv.processInfo.environment["API_KEY"] == "secret-key")

        Dotenv.set(value: "super-secret-key", forKey: "API_KEY", overwrite: false)

        #expect(Dotenv.processInfo.environment["API_KEY"] == "secret-key")
    }
}
