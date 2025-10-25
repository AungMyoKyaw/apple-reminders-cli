// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "reminder",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "reminder",
            targets: ["reminder"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4")
    ],
    targets: [
        .executableTarget(
            name: "reminder",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "apple-reminders-cli",
            sources: ["main.swift"]
        )
    ]
)
