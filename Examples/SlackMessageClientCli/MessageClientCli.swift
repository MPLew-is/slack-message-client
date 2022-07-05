import Foundation

import BlockKitMessage
import SlackMessageClient

import ArgumentParser
import AsyncHTTPClient
import Yams


/// An object representing configuration values for the message client
struct MessageClientConfiguration: Codable {
	/// Slack API authentication token (most likely [a bot token](https://api.slack.com/authentication/token-types#bot) beginning with `xoxb-`).
	let authToken: String
	/// Slack channel ID to post the message to
	let channel: String?
}

@main
struct MessageClientCli: AsyncParsableCommand {
	@Option(name: [.customLong("config"), .customShort("f")], help: "Path to config file to pull at least the authentication token from")
	var configurationFile: String = "config.yaml"


	@Option(name: [.long, .short], help: "Slack channel ID to post the message to (optional if specified in the config file)")
	var channel: String?


	@Option(name: [.long, .short], help: "Text contents of the header block in the example message")
	var header: String = "Example header"

	@Option(name: [.long, .short], help: "Text contents of the section block in the example message")
	var section: String = "Example section"

	@Option(name: [.long, .short], help: "GitHub username for the context block in the example message")
	var user: String = "MPLew-is"


	func run() async throws {
		let configurationData: Data = try .init(contentsOf: .init(fileURLWithPath: configurationFile))
		let decoder = YAMLDecoder()
		let configuration = try decoder.decode(MessageClientConfiguration.self, from: configurationData)

		let channel: String? = self.channel ?? configuration.channel
		guard let channel = channel else {
			throw ValidationError("A channel is required, either via a config file or command line parameter")
		}

		let client: MessageClient = .init(authToken: configuration.authToken)


		// An example Slack message with header, section, and context blocks
		let message = Message.build {
			Header(header)

			Section(mrkdwn: section)

			Context.build {
				Image(url: "https://github.com/\(user).png", alternateText: "\(user) profile picture")
				Mrkdwn(user)
			}
		}

		try await client.post(channel: channel, message: message)
	}
}
