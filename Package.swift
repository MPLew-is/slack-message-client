// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "BlockKitMessage",
	products: [
		.library(
			name: "BlockKitMessage",
			targets: ["BlockKitMessage"]
		),
	],
	dependencies: [],
	targets: [
		.target(
			name: "BlockKitMessage",
			dependencies: []
		),
		.testTarget(
			name: "BlockKitMessageTests",
			dependencies: ["BlockKitMessage"]
		),
	]
)
