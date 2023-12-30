// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlotView",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "PlotView",
            targets: ["PlotView"]),
    ],
    dependencies: [
        .package(url: "git@github.com:iharkatkavets/grid-view.ios.swift.git", from: "0.1.5")
    ],
    targets: [
        .target(
            name: "PlotView",
            dependencies: [
                .product(name: "GridView", package: "grid-view.ios.swift")]),
        .testTarget(
            name: "PlotViewTests",
            dependencies: ["PlotView"]),
    ]
)
