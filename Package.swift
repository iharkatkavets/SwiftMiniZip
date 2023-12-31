// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMiniZip",
    platforms: [.iOS(.v15),.macOS(.v10_14)],
    products: [
        .library(
            name: "SwiftMiniZip",
            targets: ["SwiftMiniZip"]),
    ],
    targets: [
        .target(
            name: "SwiftMiniZip",
            dependencies: ["cminizip"],
            path: "Sources"),
        .target(
            name: "cminizip",
            path: "cminizip"),
        .testTarget(
            name: "SwiftMiniZipTests",
            dependencies: ["SwiftMiniZip"],
            path: "Tests",
            resources: [
                .copy("Resources/complex.zip"),
                .copy("Resources/complexprotected.zip"),
                .copy("Resources/OriginFile.txt"),
                .copy("Resources/FirstFolder"),
                .copy("Resources/protected.zip"),
                .copy("Resources/regular.zip"),
            ]),
    ]
    
)
