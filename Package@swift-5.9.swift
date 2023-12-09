// swift-tools-version:5.9
import PackageDescription
import CompilerPluginSupport

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
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "509.0.2")),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.2.2")),
    ],
    targets: [
        .target(name: "SQLKit", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "NIO", package: "swift-nio"),
            .target(name: "SQLModelMacro"),
        ]),
        .macro(
          name: "SQLModelMacro",
          dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
          ]
        ),
        .target(name: "SQLKitBenchmark", dependencies: [
            .target(name: "SQLKit")
        ]),
        .testTarget(name: "SQLKitTests", dependencies: [
            .target(name: "SQLKit"),
            .target(name: "SQLKitBenchmark"),
        ]),
        .testTarget(
            name: "SQLModelMacroTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .target(name: "SQLKit"),
            ]
        )
    ]
)
