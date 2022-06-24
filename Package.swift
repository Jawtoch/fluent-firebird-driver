// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FirebirdFluentDriver",
	platforms: [
		.macOS(.v12)
	],
    products: [
        .library(
            name: "FirebirdFluentDriver",
            targets: ["FirebirdFluentDriver"]),
    ],
    dependencies: [
		.package(name: "FirebirdSQL", path: "../FirebirdSQL"),
		.package(url: "https://github.com/vapor/fluent-kit.git", from: "1.27.0"),
    ],
    targets: [
        .target(
            name: "FirebirdFluentDriver",
            dependencies: [
				.product(name: "FirebirdSQL", package: "FirebirdSQL"),
				.product(name: "FluentKit", package: "fluent-kit"),
				.product(name: "FluentSQL", package: "fluent-kit"),
			]),
        .testTarget(
            name: "FirebirdFluentDriverTests",
            dependencies: ["FirebirdFluentDriver"]),
    ]
)
