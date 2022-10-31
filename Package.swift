// swift-tools-version:5.1.0

import PackageDescription

let package = Package(
    name: "fluent-firebird-driver",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "FluentFirebirdDriver",
                 targets: ["FluentFirebirdDriver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ugocottin/firebird-kit.git",
                 from: "2.0.1"),
        .package(url: "https://github.com/vapor/fluent-kit.git",
                 from: "1.27.0"),
    ],
    targets: [
        .target(name: "FluentFirebirdDriver",
                dependencies: [
                    .product(name: "FirebirdSQL",
                             package: "firebird-kit"),
                    .product(name: "FluentKit",
                             package: "fluent-kit"),
                    .product(name: "FluentSQL",
                             package: "fluent-kit"),
                ]),
    ]
)
