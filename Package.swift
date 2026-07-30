// swift-tools-version:6.1
import PackageDescription

/// `.when(platforms:)` can only include, never exclude, so excluding WASI means listing everything else.
/// This list matches the [supported platforms on the Swift 6.1 release of SPM](https://github.com/swiftlang/swift-package-manager/blob/release/6.1/Sources/PackageDescription/SupportedPlatforms.swift).
/// Don't add new platforms here unless raising the swift-tools-version of this manifest.
let allPlatforms: [Platform] = [.macOS, .macCatalyst, .iOS, .tvOS, .watchOS, .visionOS, .driverKit, .linux, .windows, .android, .wasi, .openbsd]
let nonWASIPlatforms: [Platform] = allPlatforms.filter { $0 != .wasi }

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
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.84.0"),
    ],
    targets: [
        .target(
            name: "SQLKit",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
                // NIOCore itself builds for wasm32-unknown-wasip1, but the drivers beneath SQLKit
                // cannot build SwiftNIO there (NIOPosix needs POSIX sockets and threads), so no
                // driver on that platform could implement an `EventLoopFuture` surface. Target
                // dependency conditions are evaluated per platform, so on WASI NIOCore is simply
                // not linked and that surface drops out via `#if canImport(NIOCore)`; the async
                // surface is unaffected.
                .product(name: "NIOCore", package: "swift-nio", condition: .when(platforms: nonWASIPlatforms)),
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
                // The test suite exercises the SwiftNIO surface, so it is not built for WASI.
                .product(name: "NIOCore", package: "swift-nio", condition: .when(platforms: nonWASIPlatforms)),
                .product(name: "NIOEmbedded", package: "swift-nio", condition: .when(platforms: nonWASIPlatforms)),
                .target(name: "SQLKit"),
                .target(name: "SQLKitBenchmark"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    // .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
] }
