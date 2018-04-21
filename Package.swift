// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SQL",
    products: [
        .library(name: "SQL", targets: ["SQL"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SQL", dependencies: []),
        .testTarget(name: "SQLTests", dependencies: ["SQL"]),
    ]
)
