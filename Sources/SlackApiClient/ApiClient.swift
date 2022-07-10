import Foundation

import AsyncHTTPClient
import NIOCore


/**
Slack API client that auto-injects required headers such as authentication tokens

This client is intended to be a drop-in replacement for normal `AsyncHTTPClient` usage, with automatic handling for authentication and any other required headers or configuration.

This must be a `class` to provide `deinit` capabilities to shut down the embedded `AsyncHTTPClient` instance.
*/
public class SlackApiClient {
	private static let userAgent: String = "swift-server/async-http-client"

	/// Stored `AsyncHTTPClient` client object, either auto-created or input by the user
	let httpClient: HTTPClient
	/// Whether this wrapper should shut down the HTTP client on `deinit`
	private let shouldShutdownHttpClient: Bool

	/**
	Slack authentication token string to be injected on every request.

	This is most likely [a bot token](https://api.slack.com/authentication/token-types#bot) beginning with `xoxb-`.
	**/
	let authToken: String

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
	*/
	public func execute(_ originalRequest: HTTPClientRequest, timeout: NIOCore.TimeAmount = .seconds(10)) async throws -> HTTPClientResponse {
		var modifiedRequest = originalRequest
		modifiedRequest.headers.add(name: "Authorization", value: "Bearer \(self.authToken)")
		modifiedRequest.headers.add(name: "User-Agent",    value: Self.userAgent)

		return try await self.httpClient.execute(modifiedRequest, timeout: timeout)
	}
}
