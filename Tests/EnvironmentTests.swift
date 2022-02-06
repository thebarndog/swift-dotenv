//
//  EnvironmentTests.swift
//  SwiftDotenv
//
//  Created by Brendan Conron on 10/17/21.
//

import SwiftDotenv
import XCTest

final class EnvironmentTests: XCTestCase {
    
    func testCreatingEnvironmentFromStringDictionary() throws {
        let env = try Environment(values: [
            "API_KEY": "some-secret",
            "ONBOARDING_ENABLED": "true",
            "NETWORK_RETRIES": "3",
            "NETWORK_TIMEOUT": "10.5"
        ])
        
        // implicitly testing string subscripting
        XCTAssertEqual(env["API_KEY"], .string("some-secret"))
        XCTAssertEqual(env["ONBOARDING_ENABLED"], .boolean(true))
        XCTAssertEqual(env["NETWORK_RETRIES"], .integer(3))
        XCTAssertEqual(env["NETWORK_TIMEOUT"], .double(10.5))
    }
    
    func testCreatingEnvironmentFromTypeSafeConstruct() throws {
        let env = try Environment(values: [
            "apiKey": .string("some-secret"),
            "onboardingEnabled": .boolean(true),
            "networkRetries": .integer(3),
            "networkTimeout": .double(10.5)
        ])
        
        // implicitly testing subscripting
        XCTAssertEqual(env.apiKey, .string("some-secret"))
        XCTAssertEqual(env.onboardingEnabled, .boolean(true))
        XCTAssertEqual(env.networkRetries, .integer(3))
        XCTAssertEqual(env.networkTimeout, .double(10.5))
    }

    // MARK: - Adding and Removing Values

    func testAddingValueForNonexistantKey() throws {
        var environment = try Environment()

        XCTAssertNil(environment.key)

        environment.setValue(.integer(1), forKey: "key")

        XCTAssertEqual(environment.key, .integer(1))
    }

    func testAddingValueForExistingKeyWithoutForcing() throws {
        var environment = try Environment(values: [
            "key": .integer(1)
        ])

        XCTAssertEqual(environment.key, .integer(1))

        environment.setValue(.integer(2), forKey: "key")

        XCTAssertEqual(environment.key, .integer(1))
    }

    func testAddingValueForExistingValueWithForcing() throws {
        var environment = try Environment(values: [
            "key": .integer(1)
        ])

        XCTAssertEqual(environment.key, .integer(1))

        environment.setValue(.integer(2), forKey: "key", force: true)

        XCTAssertEqual(environment.key, .integer(2))
    }

    func testRemovingNonexistantValue() throws {
        var environment = try Environment()

        XCTAssertNil(environment.key)

        let oldValue = environment.removeValue(forKey: "key")

        XCTAssertNil(oldValue)
    }


    func testRemovingValue() throws {
        var environment = try Environment(values: [
            "key": .integer(1)
        ])

        XCTAssertNotNil(environment.key)

        let oldValue = environment.removeValue(forKey: "key")

        XCTAssertEqual(oldValue, .integer(1))
        XCTAssertNil(environment.key)
    }
}
