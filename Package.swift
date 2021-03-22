// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "fluent-firebird-driver",
	platforms: [
		.macOS(.v10_15),
	],
    products: [
        .library(
            name: "FluentFirebirdDriver",
            targets: ["FluentFirebirdDriver"]),
    ],
    dependencies: [
		.package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0"),
		.package(name: "firebird-kit", path: "../firebird-kit")
    ],
    targets: [
        .target(
            name: "FluentFirebirdDriver",
            dependencies: [
				.product(name: "FluentKit", package: "fluent-kit"),
				.product(name: "FluentSQL", package: "fluent-kit"),
				.product(name: "FirebirdKit", package: "firebird-kit"),
			]),
        .testTarget(
            name: "FluentFirebirdDriverTests",
            dependencies: ["FluentFirebirdDriver"]),
    ]
)
