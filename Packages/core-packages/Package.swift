// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "essentia-core-packages",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        ),
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "CoreMock",
            targets: ["CoreMock"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [],
            path: "DesignSystem/Sources/DesignSystem",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            path: "DesignSystem/Tests/DesignSystemTests"
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")
            ],
            path: "Core/Sources/Core",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .target(
            name: "CoreMock",
            dependencies: ["Core"],
            path: "Core/Sources/CoreMock",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "CoreMock"],
            path: "Core/Tests/CoreTests"
        )
    ]
)
