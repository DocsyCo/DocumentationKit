// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocumentationKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "DocumentationKit",
            targets: ["DocumentationKit"]
        ),
        .library(name: "DocumentationRenderer", targets: ["DocumentationRenderer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-docc.git", revision: "30bc32eecf7196eb39ac2854f1e1dfcd6b6e5513"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0-beta.6"),
    ],
    targets: [
        .target(
            name: "DocumentationKit",
            dependencies: [
                .product(name: "SwiftDocC", package: "swift-docc"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Atomics", package: "swift-atomics"),
            ]
        ),
        .testTarget(
            name: "DocumentationKitTests",
            dependencies: ["DocumentationKit"]
        ),
        .target(
            name: "DocumentationRenderer",
            dependencies: ["DocumentationKit"]
        ),
    ]
)
