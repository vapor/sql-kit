// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "sql-kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "SQLKit", targets: ["SQLKit"]),
        .library(name: "SQLKitBenchmark", targets: ["SQLKitBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "SQLKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "Collections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SQLKitBenchmark",
            dependencies: [
                .target(name: "SQLKit"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SQLKitTests",
            dependencies: [
                .target(name: "SQLKit"),
                .target(name: "SQLKitBenchmark"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency=complete"),
] }
