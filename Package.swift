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
        .library(name: "AffirmationsClient", targets: ["AffirmationsClient"]),
        .library(name: "AppCore", targets: ["AppCore"]),
        .library(name: "ComposableStoreKit", targets: ["ComposableStoreKit"]),
        .library(name: "ComposableUserNotifications", targets: ["ComposableUserNotifications"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "ImageRenderClient", targets: ["ImageRenderClient"]),
        .library(name: "NotificationHelpers", targets: ["NotificationHelpers"]),
        .library(name: "NotificationsAuthAlert", targets: ["NotificationsAuthAlert"]),
        .library(name: "RemoteNotificationsClient", targets: ["RemoteNotificationsClient"]),
        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "UIPasteboardClient", targets: ["UIPasteboardClient"]),
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
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-gen",
            from: "0.4.0"
        )
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                "ComposableUserNotifications",
                "HomeFeature",
                "NotificationHelpers",
                "RemoteNotificationsClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AffirmationsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Gen", package: "swift-gen"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ComposableStoreKit",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "ComposableUserNotifications",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "AffirmationsClient",
                "ComposableStoreKit",
                "ImageRenderClient",
                "UIApplicationClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .process("Resources/assets")
            ]
        ),
        .target(
            name: "ImageRenderClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "NotificationHelpers",
            dependencies: [
                "ComposableUserNotifications",
                "RemoteNotificationsClient"
            ]
        ),
        .target(
            name: "NotificationsAuthAlert",
            dependencies: [
                "ComposableUserNotifications",
                "NotificationHelpers",
                "RemoteNotificationsClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "RemoteNotificationsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "UIApplicationClient",
            dependencies: [
                "UIPasteboardClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "UIPasteboardClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
    ]
)
