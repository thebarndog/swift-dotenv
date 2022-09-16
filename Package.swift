// swift-tools-version:5.7
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
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "SwiftDotenv",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
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
