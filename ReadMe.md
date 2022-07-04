# BlockKitMessage #

This package provides a Swift object model for [a Slack Block Kit message](https://api.slack.com/block-kit), as well as a [Result Builder](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md) convenience interface for easy message creation.
This is still in extremely early development, and only supports a narrow subset of the full Block Kit API.


## Quick Start ##

Add to your `Package.Swift`:
```swift
...
	dependencies: [
		...
		.package(url: "https://github.com/MPLew-is/block-kit-message", .branch("main")),
	],
	targets: [
		...
		.target(
			...
			dependencies: [
				...
				.product(name: "BlockKitMessage", package: "block-kit-message"),
			]
		),
		...
	]
]
```

Create and encode your first message:
```swift
import BlockKitMessage

let message = Message.build {
	Header("Header")

	Section(mrkdwn: "Section")

	Context.build {
		Image(url: "https://example.com", alternateText: "Alt text")
		Mrkdwn("User")
	}
}

print(String(data: try JSONEncoder().encode(message), encoding: .utf8)!)
```
