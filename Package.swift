// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMiniZip",
    products: [
        .library( name: "SwiftMiniZip", type: .static, targets: ["SwiftMiniZip"]),
        .library( name: "cminizip", type: .static, targets: ["cminizip"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftMiniZip",
            dependencies: [
                "cminizip",
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources"
            ),
        .target(
            name: "cminizip",
            path: "cminizip",
            cSettings: [
                .headerSearchPath("cminizip/include")
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
            ),
        .testTarget(
            name: "SwiftMiniZipTests",
            dependencies: ["SwiftMiniZip"],
            path: "Tests",
            resources: [
                .copy("Resources/complex.zip"),
                .copy("Resources/complexprotected.zip"),
                .copy("Resources/OriginFile.txt"),
                .copy("Resources/OriginFile.txt.zip"),
                .copy("Resources/OriginFile.txt.encrypted.zip"),
                .copy("Resources/protected.zip"),
                .copy("Resources/regular.zip"),
            ]
            ),
    ]

)
