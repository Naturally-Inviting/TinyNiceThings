// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinyNiceThings",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "AffirmationsClient", targets: ["AffirmationsClient"]),
        .library(name: "AppCore", targets: ["AppCore"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.47.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
            from: "0.2.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.11.0"
        )
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                "AffirmationsClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AffirmationsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
