// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dotenv",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwiftDotenv",
            targets: ["SwiftDotenv"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftDotenv",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftDotenvTests",
            dependencies: ["SwiftDotenv"],
            path: "Tests",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
