// swift-tools-version:5.2.0

import PackageDescription

let package = Package(
    name: "FirebirdFluentDriver",
	platforms: [
		.macOS(.v10_15),
	],
    products: [
        .library(
            name: "FirebirdFluentDriver",
            targets: ["FirebirdFluentDriver"]),
    ],
    dependencies: [
		.package(
			url: "https://github.com/ugocottin/FirebirdSQL.git",
			from: "0.1.0"),
		.package(
			url: "https://github.com/vapor/fluent-kit.git",
			from: "1.27.0"),
    ],
    targets: [
        .target(
            name: "FirebirdFluentDriver",
            dependencies: [
				.product(
					name: "FirebirdSQL",
					package: "FirebirdSQL"),
				.product(
					name: "FluentKit",
					package: "fluent-kit"),
				.product(
					name: "FluentSQL",
					package: "fluent-kit"),
			]),
        .testTarget(
            name: "FirebirdFluentDriverTests",
            dependencies: [
				.target(name: "FirebirdFluentDriver"),
			]),
    ]
)
