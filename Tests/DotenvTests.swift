//
//  DotenvTests.swift
//  SwiftDotenvTests
//
//  Created by Brendan Conron on 10/17/21.
//

import SwiftDotenv
import XCTest

final class DotenvTests: XCTestCase {

    private static var temporarySaveLocation: String {
        "\(NSTemporaryDirectory())swift-dotenv/"
    }

    override func setUpWithError() throws {
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: Self.temporarySaveLocation),
            withIntermediateDirectories: true, attributes: nil
        )
        guard let path = Bundle.module.path(forResource: "fixture", ofType: "env") else {
            XCTFail("unable to find env file")
            return
        }

        try Dotenv.configure(atPath: path)

    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: Self.temporarySaveLocation) {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: Self.temporarySaveLocation))
        }
    }

    func testConfiguringEnvironment() throws {
        XCTAssertEqual(Dotenv.apiKey, .string("some-value"))
        XCTAssertEqual(Dotenv.buildNumber, .integer(5))
        XCTAssertEqual(Dotenv.identifier, .string("com.app.example"))
        XCTAssertEqual(Dotenv.mailTemplate, .string("The \"Quoted\" Title"))
        XCTAssertEqual(Dotenv.dbPassphrase, .string("1qaz?#@\"' wsx$"))
        XCTAssertNil(Dotenv.nonExistentValue)
    }

    func testSubscriptingByStrings() throws {
        // implicitly testing string subscripting
        XCTAssertEqual(Dotenv["API_KEY"], .string("some-value"))
        XCTAssertEqual(Dotenv["BUILD_NUMBER"], .integer(5))
        XCTAssertEqual(Dotenv["IDENTIFIER"], .string("com.app.example"))
    }

    func testSubscriptingNonexistantValue() {
        XCTAssertNil(Dotenv.randomVariable)
    }

    func testSettingValues() {
        Dotenv.set(value: "1234", forKey: "API_KEY")

        XCTAssertEqual(Dotenv.apiKey, .integer(1234))
        XCTAssertEqual(Dotenv.processInfo.environment["API_KEY"], "1234")
    }

    func testOverridingValues() {
        setenv("API_KEY", "1234", 1)

        XCTAssertEqual(Dotenv.processInfo.environment["API_KEY"], "1234")

        Dotenv.set(value: "secret-key", forKey: "API_KEY", overwrite: true)

        XCTAssertEqual(Dotenv.processInfo.environment["API_KEY"], "secret-key")

        Dotenv.set(value: "super-secret-key", forKey: "API_KEY", overwrite: false)

        XCTAssertEqual(Dotenv.processInfo.environment["API_KEY"], "secret-key")
    }
}

