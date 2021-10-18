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
}
