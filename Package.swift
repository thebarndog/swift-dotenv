// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dotenv",
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
