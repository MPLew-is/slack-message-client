/// Object representing any raw/untagged Block Kit block content that can be used as [a top-level block in a message](https://api.slack.com/reference/block-kit/blocks)
public protocol BlockContent: Codable {}

extension Header: BlockContent {}
extension Section: BlockContent {}
extension Context: BlockContent {}

// Add a convenience result builder for creating a message.
public extension Message {
	/// Helper object to enable result builder syntax for writing a message
	@resultBuilder
	struct MessageBuilder {
		/**
		Build wrapped Block Kit blocks from their raw content.

		- Parameter contents: objects representing the raw content of the blocks constituting this message
		- Returns: Wrapped objects containing the input contents, which can be parsed or encoded for the output message
		*/
		public static func buildBlock(_ contents: BlockContent...) -> [Block] {
			return contents.compactMap { .init(wrapping: $0) }
		}
	}

	/**
	Initialize an instance given the output of a result builder.

	This unfortunately cannot just be an `init` since the `Decodable` initializer seems to be selected by the compiler when actually writing a result builder block, even though that won't compile.

	- Parameter builder: closure representing the output of a result builder block
	*/
	static func build(@MessageBuilder _ builder: () -> [Block]) -> Self {
		return .init(blocks: builder())
	}
}


/// Object representing any raw/untagged Block Kit context block content that can be used as a top-level element inside [a context block](https://api.slack.com/reference/block-kit/blocks#context)
public protocol ContextElementContent: Codable {}

extension Image: ContextElementContent {}
extension Mrkdwn: ContextElementContent {}
extension PlainText: ContextElementContent {}

// Add a convenience result builder for creating a message.
public extension Context {
	/// Helper object to enable result builder syntax for writing the contents of a context block
	@resultBuilder
	struct ContextBlockBuilder {
		/**
		Build wrapped Block Kit context block elements from their raw content.

		- Parameter contents: objects representing the raw content of the elements constituting this context block
		- Returns: Wrapped objects containing the input contents, which can be parsed or encoded for the output block
		*/
		public static func buildBlock(_ contents: ContextElementContent...) -> [ContextElement] {
			return contents.compactMap { .init(wrapping: $0) }
		}
	}

	/**
	Initialize an instance given the output of a result builder.

	This unfortunately cannot just be an `init` since the `Decodable` initializer seems to be selected by the compiler when actually writing a result builder block, even though that won't compile.

	- Parameter builder: closure representing the output of a result builder block
	*/
	static func build(id: String? = nil, @ContextBlockBuilder _ builder: () -> [ContextElement]) -> Self {
		return .init(id: id, elements: builder())
	}
}


public extension Header {
	/**
	Create an instance from a pre-wrapped plain text object.

	- Parameters:
		- text: pre-wrapped `PlainText` object representing the header's contents
		- id: optional string identifier for the block
	*/
	init(_ text: PlainText, id: String? = nil) {
		self.id = id
		self.text = .plainText(text)
	}

	/**
	Create an instance from a raw string.

	- Parameters:
		- text: string of the header's contents
		- id: optional string identifier for the block
	*/
	init(_ text: String, id: String? = nil) {
		self.id = id
		self.text = .plainText(.init(text))
	}
}


public extension Section {
	/**
	Create a mrkdwn instance from a pre-wrapped mrkdwn object.

	- Parameters:
		- text: pre-wrapped `Mrkdwn` object representing the section's contents
		- id: optional string identifier for the block
	*/
	init(mrkdwn: Mrkdwn, id: String? = nil) {
		self.id = id
		self.text = .mrkdwn(mrkdwn)
	}

	/**
	Create a mrkdwn instance from a raw string.

	- Parameters:
		- text: string of the sections's contents
		- id: optional string identifier for the block
	*/
	init(mrkdwn: String, id: String? = nil) {
		self.id = id
		self.text = .mrkdwn(.init(mrkdwn))
	}


	/**
	Create a plain text instance from a pre-wrapped plain text object.

	- Parameters:
		- text: pre-wrapped `PlainText` object representing the section's contents
		- id: optional string identifier for the block
	*/
	init(plainText: PlainText, id: String? = nil) {
		self.id = id
		self.text = .plainText(plainText)
	}

	/**
	Create a plain text instance from a raw string.

	- Parameters:
		- text: string of the sections's contents
		- id: optional string identifier for the block
	*/
	init(plainText: String, id: String? = nil) {
		self.id = id
		self.text = .plainText(.init(plainText))
	}
}


public extension Mrkdwn {
	/**
	Create an instance from an unlabeled string value.

	- Parameter string: string value representing the mrkdwn contents
	*/
	init(_ string: String) {
		self.text = string
		self.interpretLinksVerbatim = nil
	}
}

// Allow a mrkdwn block to be converted from a string literal while writing a result builder block.
extension Mrkdwn: ExpressibleByStringInterpolation {
	public init(stringLiteral: String) {
		self.init(stringLiteral)
	}
}


public extension PlainText {
	/**
	Create an instance from an unlabeled string value.

	- Parameter string: string value representing the plain text contents
	*/
	init(_ string: String) {
		self.text = string
		self.convertEscapedEmoji = nil
	}
}

// Allow a plaintext block to be converted from a string literal while writing a result builder block.
extension PlainText: ExpressibleByStringInterpolation {
	public init(stringLiteral: String) {
		self.init(stringLiteral)
	}
}

