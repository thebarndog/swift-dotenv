@testable import SwiftDotenv
import XCTest

final class DotenvAsyncTests: XCTestCase {
    
    private static var temporarySaveLocation: String {
        "\(NSTemporaryDirectory())swift-dotenv-async/"
    }
    
    override func setUp() async throws {
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: Self.temporarySaveLocation),
            withIntermediateDirectories: true, attributes: nil
        )
        
    }
    
    func testAsyncConfigure() async throws {
        guard let path = Bundle.module.path(forResource: "fixture", ofType: "env") else {
            XCTFail("unable to find env file")
            return
        }
        try await Dotenv.configure(atPath: path)
    }
}
