protocol BlockContent: Codable {}

extension Header: BlockContent {}
extension Section: BlockContent {}
extension Context: BlockContent {}

// Add a convenience result builder for creating a message.
extension Message {
	@resultBuilder
	struct MessageBuilder {
		static func buildBlock(_ blocks: BlockContent...) -> [Block] {
			return blocks.compactMap { .init(wrapping: $0) }
		}
	}

	/**
	Initialize an instance given the output of a result builder.

	This unfortunately cannot just be an `init` since the `Decodable` initializer seems to be selected by the compiler when actually writing a result builder block, even though that won't compile.

	- Parameter: closure representing the output of a result builder block
	*/
	static func build(@MessageBuilder _ builder: () -> [Block]) -> Self {
		return .init(blocks: builder())
	}
}


protocol ContextElementContent: Codable {}
extension Image: ContextElementContent {}
extension Mrkdwn: ContextElementContent {}
extension PlainText: ContextElementContent {}

// Add a convenience result builder for creating a message.
extension Context {
	@resultBuilder
	struct ContextBlockBuilder {
		static func buildBlock(_ elements: ContextElementContent...) -> [ContextElement] {
			return elements.compactMap { .init(wrapping: $0) }
		}
	}

	/**
	Initialize an instance given the output of a result builder.

	This unfortunately cannot just be an `init` since the `Decodable` initializer seems to be selected by the compiler when actually writing a result builder block, even though that won't compile.

	- Parameter: closure representing the output of a result builder block
	*/
	static func build(id: String? = nil, @ContextBlockBuilder _ builder: () -> [ContextElement]) -> Self {
		return .init(id: id, elements: builder())
	}
}


// Allow a mrkdwn block to be converted from a string literal while writing a result builder block.
extension Mrkdwn: ExpressibleByStringLiteral {
	init(stringLiteral: String) {
		self.text = stringLiteral
		self.interpretLinksVerbatim = nil
	}
}

// Allow a plaintext block to be converted from a string literal while writing a result builder block.
extension PlainText: ExpressibleByStringLiteral {
	init(stringLiteral: String) {
		self.text = stringLiteral
		self.convertEscapedEmoji = nil
	}
}

