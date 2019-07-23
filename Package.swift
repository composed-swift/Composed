// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Composed",
    products: [
        .library(
            name: "Composed",
            targets: ["Composed"]),
    ],
    dependencies: [
        .package(url: "https://github.com/quick/quick", from: "2.0.0"),
        .package(url: "https://github.com/quick/nimble", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "Composed",
            dependencies: []),
        .testTarget(
            name: "ComposedTests",
            dependencies: ["Quick", "Nimble", "Composed"]),
    ]
)
