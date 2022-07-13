import Foundation

import AsyncHTTPClient
import NIOHTTP1

import BlockKitMessage
import SlackApiClient


/// Slack Block Kit message client to post an input message object to a channel
public struct SlackMessageClient {
	/// Underlying authenticated API client to actually execute the requests
	public let apiClient: SlackApiClient

	/**
	Create an instance of the message client from its component properties.

	- Parameters:
		- authToken: Slack API authentication token to be injected on every request
		- httpClient: if not provided, the instance will create a new one and destroy it on `deinit`
	*/
	public init(authToken: String, httpClient: HTTPClient? = nil) {
		self.apiClient = .init(authToken: authToken, httpClient: httpClient)
	}


	/**
	An object representing the top-level body of the HTTP request for posting a message

	Note that a custom `Encodable` implementation has been written to flatten the structure so the message metadata (channel, etc.) are inline with the message contents (blocks, text, etc.).
	*/
	private struct PostMessageRequest: Encodable {
		let channel: String
		let message: Message

		enum CodingKeys: String, CodingKey {
			case channel
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: Self.CodingKeys.self)
			try container.encode(self.channel, forKey: .channel)

			try self.message.encode(to: encoder)
		}
	}

	/// An object representing the top-level body of the HTTP response from posting a message
	private struct PostMessageResponse: Decodable {
		let ok: Bool
	}

	/// An enum of possible errors arising during posting the message
	public enum PostMessageError: Error {
		/**
		A non-success HTTP status code was returned

		The HTTP response code enum will be attached as an associated value for debugging.
		*/
		case httpError(HTTPResponseStatus)

		/**
		A success HTTP status code was returned, but Slack indicated a problem with the message

		The full response message will be attached as an associated value for debugging.
		*/
		case slackError(String)
	}

	/**
	Post an input message object to the input channel.

	- Parameters:
		- channel: Slack channel ID string where the message should be posted
		- message: message object representing the message to post
	*/
	public func post(_ message: Message, to channel: String) async throws {
		let requestBody: PostMessageRequest = .init(channel: channel, message: message)
		let requestBody_json: Data = try JSONEncoder().encode(requestBody)

		var request: HTTPClientRequest = SlackApiEndpoint.chat_postMessage.request
		// Slack will complain with a warning if the character set is not specified.
		request.headers.add(name: "Content-Type", value: "application/json; charset=utf-8")
		request.body = .bytes(requestBody_json)

		let response = try await self.apiClient.execute(request)

		if response.status != .ok {
			throw PostMessageError.httpError(response.status)
		}

		let responseBody_json: Data = .init(buffer: try await response.body.collect(upTo: 32 * 1024))
		let responseBody: PostMessageResponse = try JSONDecoder().decode(PostMessageResponse.self, from: responseBody_json)

		if !responseBody.ok {
			throw PostMessageError.slackError(.init(data: responseBody_json, encoding: .utf8)!)
		}
	}
}
