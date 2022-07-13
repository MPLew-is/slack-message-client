# Slack Message Client #

This package provides a Swift object model for [a Slack Block Kit message](https://api.slack.com/block-kit), as well as a [Result Builder](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md) convenience interface for easy message creation.
Also provides an asynchronous API client for sending messages based on [the `async-http-client` from the Swift Server Workgroup](https://github.com/swift-server/async-http-client).

This is still in **extremely early development**, and only currently supports sending messages and a narrow subset of the full Block Kit API.


## Quick Start ##

See [the command-line interface example](./Examples/SlackMessageClientCli) for an example implementation runnable from the command line, with configurable message text.

Add to your `Package.Swift`:
```swift
...
	dependencies: [
		...
		.package(url: "https://github.com/MPLew-is/slack-message-client", branch: "main"),
	],
	targets: [
		...
		.target(
			...
			dependencies: [
				...
				.product(name: "BlockKitMessage", package: "slack-message-client"),
				.product(name: "SlackMessageClient", package: "slack-message-client"),
			]
		),
		...
	]
]
```

Create and send a message:
```swift
import BlockKitMessage
import SlackMessageClient

@main
struct SlackMessageExample {
	static func main() async throws {
		let message = Message.build {
			Header("Header")

			Section(mrkdwn: "Section")

			Context.build {
				Image(url: "https://example.com", alternateText: "Alt text")
				Mrkdwn("User")
			}
		}

		let client = SlackMessageClient(authToken: "YOUR_SLACK_BOT_TOKEN")
		try await client.post(message, to: "YOUR_SLACK_CHANNEL_ID")
	}
}
```
(See [the command-line interface example](./Examples/SlackMessageClientCli) for more detailed instructions on how to set up a Slack app and get the required authentication/configuration values)


## Targets provided ##

- `BlockKitMessage`: object model for a Slack Block Kit message, if you just want to create messages but not send them
	- A `Message` object conforms to `Codable`, so you can use this to just generate the JSON expected by Slack, for instance

- `SlackApiClient`: a thin wrapper around [an `AsyncHTTPClient`](https://github.com/swift-server/async-http-client) which auto-injects the correct headers needed for the Slack API
	- You can use this by itself if you want to perform actions against the Slack API other than `chat.postMessage`

- `SlackMessageClient`: full client integrating the previous two targets into a simple interface for sending messages to a channel


## Features supported and planned ##

If you don't see something on this list, it's not currently planned.
Feel free to file an issue/PR to change that though.


### Block Kit ###

- [ ] Top-level message objects
	- [x] Basic integration (`blocks` argument)
	- [ ] Alternate text (`text` argument)

- [ ] `Mrkdwn` result builder
	- Basic support for `mrkdwn` embedded in a string is already present, this will just provide a better way to build complicated messages

- [x] [Header blocks](https://api.slack.com/reference/block-kit/blocks#header)

- [x] [Section blocks](https://api.slack.com/reference/block-kit/blocks#section)
	- [x] Basic support (text)
	- Fields and accessories not currently planned

- [x] [Context blocks](https://api.slack.com/reference/block-kit/blocks#context)

- [ ] [Divider blocks](https://api.slack.com/reference/block-kit/blocks#divider)

- [ ] [Image blocks](https://api.slack.com/reference/block-kit/blocks#image)

- Actions, file, and input blocks not currently planned


### Slack message client ###

- [x] [`chat.postMessage` method](https://api.slack.com/methods/chat.postMessage) integration
	- [x] `channel` argument
	- Attachments and optional arguments not currently planned

- [x] Sending `Message` object

- [ ] Sending raw JSON blocks generated externally

- [ ] Optional credentials verification on initialization to fail quickly ([`api.test` method](https://api.slack.com/methods/api.test))

- [ ] Better parsing and handling of HTTP and Slack API errors
