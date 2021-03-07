// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mughal",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "Mughal",
            targets: ["Mughal"]),
    ],
    targets: [
        .systemLibrary(
            name: "CWebP",
            pkgConfig: "libwebp",
            providers: [.brew(["webp"])]
        ),
        .target(
            name: "Mughal",
            dependencies: ["CWebP"]
        ),
        .testTarget(
            name: "MughalTests",
            dependencies: ["Mughal"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
