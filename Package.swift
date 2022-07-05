// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "SlackMessageClient",
	platforms: [
		.macOS(.v11),
	],
	products: [
		.library(
			name: "BlockKitMessage",
			targets: ["BlockKitMessage"]
		),
		.library(
			name: "SlackApiClient",
			targets: ["SlackApiClient"]
		),
		.library(
			name: "SlackMessageClient",
			targets: ["SlackMessageClient"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/swift-server/async-http-client", from: "1.11.0"),
	],
	targets: [
		.target(
			name: "BlockKitMessage",
			dependencies: []
		),
		.target(
			name: "SlackApiClient",
			dependencies: [
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
			]
		),
		.target(
			name: "SlackMessageClient",
			dependencies: [
				"BlockKitMessage",
				"SlackApiClient",
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
			]
		),
		.testTarget(
			name: "BlockKitMessageTests",
			dependencies: ["BlockKitMessage"]
		),
	]
)
