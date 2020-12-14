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
            name: "ComposedData",
            targets: ["ComposedData"]),
        .library(
            name: "ComposedLayouts",
            targets: ["ComposedLayouts"]),
        .library(
            name: "ComposedUI",
            targets: ["ComposedUI"]),
    ],
    dependencies: [
        .package(name: "Quick", url: "https://github.com/quick/quick", from: "2.0.0"),
        .package(name: "Nimble", url: "https://github.com/quick/nimble", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "Composed",
            dependencies: ["ComposedData", "ComposedLayouts", "ComposedUI"]),

        .target(name: "ComposedData"),
        .testTarget(
            name: "ComposedDataTests",
            dependencies: ["Quick", "Nimble", "ComposedData"]),

        .target(
            name: "ComposedLayouts",
            dependencies: ["ComposedData", "ComposedUI"]),

        .target(
            name: "ComposedUI",
            dependencies: ["ComposedData"]),
        .testTarget(
            name: "ComposedUITests",
            dependencies: ["Quick", "Nimble", "ComposedUI"]),
    ]
)
