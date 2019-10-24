// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "sql-kit",
    products: [
        .library(name: "SQLKit", targets: ["SQLKit"]),
        .library(name: "SQLKitBenchmark", targets: ["SQLKitBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "SQLKit", dependencies: ["NIO"]),
        .target(name: "SQLKitBenchmark", dependencies: ["SQLKit"]),
        .testTarget(name: "SQLKitTests", dependencies: ["SQLKit", "SQLKitBenchmark"]),
    ]
)
