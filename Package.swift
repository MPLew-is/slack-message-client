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
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
		.package(url: "https://github.com/swift-server/async-http-client", from: "1.11.0"),
		.package(url: "https://github.com/jpsim/Yams", from: "5.0.0"),
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
		.executableTarget(
			name: "SlackMessageClientCli",
			dependencies: [
				"BlockKitMessage",
				"SlackMessageClient",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
				.product(name: "Yams", package: "Yams"),
			],
			path: "Examples/SlackMessageClientCli",
			exclude: [
				"ReadMe.md",
				"example-message.png",
				"channel-id-callout.png",
				"config.yaml",
				"config.example.yaml",
			]
		),
		.testTarget(
			name: "BlockKitMessageTests",
			dependencies: ["BlockKitMessage"]
		),
	]
)
