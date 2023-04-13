// swift-tools-version:5.6
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
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SQLKit", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "NIO", package: "swift-nio"),
        ]),
        .target(name: "SQLKitBenchmark", dependencies: [
            .target(name: "SQLKit")
        ]),
        .testTarget(name: "SQLKitTests", dependencies: [
            .target(name: "SQLKit"),
            .target(name: "SQLKitBenchmark"),
        ]),
    ]
)
