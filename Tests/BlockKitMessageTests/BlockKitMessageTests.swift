import XCTest

@testable import BlockKitMessage

final class BlockKitMessageTests: XCTestCase {
	/// Test that encoding an example result builder block results in the expected JSON output.
	func testEncodingCorrectness() throws {
		let message = Message.build {
			Header("Header")

			Section(mrkdwn: "Section")

			Context.build {
				Image(url: "https://example.com", alternateText: "Alt text")
				Mrkdwn("User")
			}
		}

		let actual = String(data: try JSONEncoder().encode(message), encoding: .utf8)!
		let expected = """
			{"blocks":[{"type":"header","text":{"type":"plain_text","text":"Header"}},{"type":"section","text":{"type":"mrkdwn","text":"Section"}},{"type":"context","elements":[{"type":"image","alt_text":"Alt text","image_url":"https:\\/\\/example.com"},{"type":"mrkdwn","text":"User"}]}]}
			"""
		XCTAssertEqual(expected, actual)
	}

	/// Test that decoding an example JSON message and then re-encoding it results in the same JSON output.
	func testRoundTripEncodingCorrectness() throws {
		let original: String = """
			{"blocks":[{"type":"header","text":{"type":"plain_text","text":"Header"}},{"type":"section","text":{"type":"mrkdwn","text":"Section"}},{"type":"context","elements":[{"type":"image","alt_text":"Alt text","image_url":"https:\\/\\/example.com"},{"type":"mrkdwn","text":"User"}]}]}
			"""

		let message = try JSONDecoder().decode(Message.self, from: original.data(using: .utf8)!)

		let actual = String(data: try JSONEncoder().encode(message), encoding: .utf8)!
		XCTAssertEqual(original, actual)
	}
}
