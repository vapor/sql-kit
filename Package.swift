// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "sql-kit",
    platforms: [
       .macOS(.v10_14),
       .iOS(.v11)
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
        .target(name: "SQLKit", dependencies: ["Logging", "NIO"]),
        .target(name: "SQLKitBenchmark", dependencies: ["SQLKit"]),
        .testTarget(name: "SQLKitTests", dependencies: ["SQLKit", "SQLKitBenchmark"]),
    ]
)
