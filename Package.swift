// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Composed",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "Composed",
            targets: ["Composed"]),
        .library(
            name: "ComposedLayouts",
            targets: ["ComposedLayouts"]),
        .library(
            name: "ComposedUI",
            targets: ["ComposedUI"]),
    ],
    dependencies: [
        .package(name: "Quick", url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
    ],
    targets: [
        .target(name: "Composed"),
        .testTarget(
            name: "ComposedTests",
            dependencies: ["Quick", "Nimble", "Composed"]),

        .target(
            name: "ComposedLayouts",
            dependencies: ["Composed", "ComposedUI"]),

        .target(
            name: "ComposedUI",
            dependencies: ["Composed"]),
        .testTarget(
            name: "ComposedUITests",
            dependencies: ["Quick", "Nimble", "ComposedUI"]),
    ]
)
