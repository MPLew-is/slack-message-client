import Foundation

import AsyncHTTPClient
import NIOCore
import NIOHTTP1


/**
Slack API client that auto-injects required headers such as authentication tokens

This client is intended to be a drop-in replacement for normal `AsyncHTTPClient` usage, with automatic handling for authentication and any other required headers or configuration.

This must be a `class` to provide `deinit` capabilities to shut down the embedded `AsyncHTTPClient` instance.
*/
public class SlackApiClient {
	/// The user agent for HTTP requests, for centralization purposes
	private static let userAgent: String = "swift-server/async-http-client"


	/// Stored async HTTP client object, either auto-created or input by the user
	private let httpClient: HTTPClient
	/// Whether this wrapper should shut down the HTTP client on `deinit`
	private let shouldShutdownHttpClient: Bool

	/**
	Slack authentication token string to be injected on every request.

	This is most likely [a bot token](https://api.slack.com/authentication/token-types#bot) beginning with `xoxb-`.
	**/
	private let authToken: String

	/**
	Create an instance of the API client from its component properties.

	- Parameters:
		- authToken: Slack API authentication token to be injected on every request
		- httpClient: if not provided, the instance will create a new one and destroy it on `deinit`
	*/
	public init(authToken: String, httpClient: HTTPClient? = nil) {
		self.authToken = authToken

		if let httpClient = httpClient {
			self.httpClient = httpClient
			self.shouldShutdownHttpClient = false
		}
		else {
			self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
			self.shouldShutdownHttpClient = true
		}
	}

	/// If this instance created its own HTTP client, shut it down.
	deinit {
		if self.shouldShutdownHttpClient {
			try? httpClient.syncShutdown()
		}
	}


	/**
	Execute an input HTTP request, injecting the authentication token and configured user agent as additional headers.

	This method passes through to and from the same method on `AsyncHTTPClient.HTTPClient`, so see that method for more complete documentation.
	- See: `AsyncHTTPClient.HTTPClient.execute`

	- Parameters:
		- request: HTTP request object to be executed (after injecting any needed authentication/etc. headers)
		- timeout: timeout for completing the HTTP request

	- Returns: An `HTTPClientResponse` from the underlying `AsyncHTTPClient` implementation, representing the response to the input request
	- Throws: Only rethrows errors from the underlying `AsyncHTTPClient` call
	*/
	public func execute(_ request: HTTPClientRequest, timeout: NIOCore.TimeAmount = .seconds(10)) async throws -> HTTPClientResponse {
		var modifiedRequest = request
		modifiedRequest.headers.add(name: "Authorization", value: "Bearer \(self.authToken)")
		modifiedRequest.headers.add(name: "User-Agent",    value: Self.userAgent)

		return try await self.httpClient.execute(modifiedRequest, timeout: timeout)
	}
}


/// Object representing a Slack API endpoint, which can provide some generated values (like its method, URL, and pre-generated request objects)
public enum SlackApiEndpoint: String {
	/// Slack API base URL, for centralization purposes
	public static let baseUrl: String = "https://slack.com/api"


	/// https://api.slack.com/methods/chat.postMessage
	case chat_postMessage = "chat.postMessage"


	/// The HTTP method associated with the endpoint
	public var method: HTTPMethod {
		switch self {
			case .chat_postMessage:
				return .POST
		}
	}

	/// The URL corresponding to the endpoint
	public var url: String {
		return "\(Self.baseUrl)/\(self)"
	}

	/// A new request object pre-configured for the given endpoint
	public var request: HTTPClientRequest {
		var request = HTTPClientRequest(url: self.url)
		request.method = self.method
		return request
	}
}
