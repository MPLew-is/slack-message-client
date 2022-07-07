/// Root object representing an entire Block Kit message
public struct Message: Codable {
	/// List of blocks containing the contents of the message
	public let blocks: [Block]
}

/**
Object wrapping [a single block in a Block Kit message](https://api.slack.com/reference/block-kit/blocks)

This is an enum of the possible block types, each with a corresponding associated value of the actual block contents.
This wrapping approach was chosen (as opposed to just having the block contents conform to a single protocol) to allow for easy traversal of the message structure in Swift simply by checking enum cases.
*/
public enum Block: FlatCodable {
	/// The wrapped block is [a header block](https://api.slack.com/reference/block-kit/blocks#header)
	case header(Header)

	/// The wrapped block is [a section block](https://api.slack.com/reference/block-kit/blocks#section)
	case section(Section)

	/// The wrapped block is [a context block](https://api.slack.com/reference/block-kit/blocks#context)
	case context(Context)


	public enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	public enum CodingValue: String, ShadowEnum {
		case header
		case section
		case context
	}
}


/// Object representing the contents of [a Block Kit header block](https://api.slack.com/reference/block-kit/blocks#header)
public struct Header: Codable {
	/// Unique identifier for this block
	public let id: String?

	/// Wrapped plain-text contents of this block
	public let text: PlainTextOnly
}

/// Object representing the contents of [a Block Kit section block](https://api.slack.com/reference/block-kit/blocks#section)
public struct Section: Codable {
	/// Unique identifier for this block
	public let id: String?

	/// Wrapped text contents of this block
	public let text: Text
}

/// Object representing the contents of [a Block Kit context block](https://api.slack.com/reference/block-kit/blocks#context)
public struct Context: Codable {
	/// Unique identifier for this block
	public let id: String?

	/// Wrapped child elements of this block
	public let elements: [ContextElement]
}


/**
Object wrapping a child element of [a Block Kit context block](https://api.slack.com/reference/block-kit/blocks#context), which can contain a text object (plain-text or mrkdwn) or an image block

This is an enum of the possible element types, each with a corresponding associated value of the actual element contents.
This wrapping approach was chosen (as opposed to just having the element contents conform to a single protocol) to allow for easy traversal of the message structure in Swift simply by checking enum cases.
*/
public enum ContextElement: FlatCodable {
	/// The wrapped context element is [a plain text object](https://api.slack.com/reference/block-kit/composition-objects#text)
	case plainText(PlainText)

	/// The wrapped context element is [a mrkdwn text object](https://api.slack.com/reference/block-kit/composition-objects#text)
	case mrkdwn(Mrkdwn)

	/// The wrapped context element is [an image block](https://api.slack.com/reference/block-kit/blocks#image)
	case image(Image)

	public enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	public enum CodingValue: String, ShadowEnum {
		case plainText = "plain_text"
		case mrkdwn
		case image
	}
}


/**
Object wrapping [a Block Kit text object](https://api.slack.com/reference/block-kit/composition-objects#text), which can contain either plain text or mrkdwn

This is an enum of the possible element types, each with a corresponding associated value of the actual element contents.
This wrapping approach was chosen (as opposed to just having the element contents conform to a single protocol) to allow for easy traversal of the message structure in Swift simply by checking enum cases.
*/
public enum Text: FlatCodable {
	/// The wrapped content is [a plain text object]((https://api.slack.com/reference/block-kit/composition-objects#text)
	case plainText(PlainText)
	/// The wrapped content is [a mrkdwn text object](https://api.slack.com/reference/block-kit/composition-objects#text)
	case mrkdwn(Mrkdwn)


	public enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	public enum CodingValue: String, ShadowEnum {
		case plainText = "plain_text"
		case mrkdwn
	}
}


/**
Object wrapping [a Block Kit plain text object](https://api.slack.com/reference/block-kit/composition-objects#text) (no mrkdwn)

This is an enum of the possible element types, each with a corresponding associated value of the actual element contents.
This wrapping approach was chosen (as opposed to just having the element contents conform to a single protocol) to allow for easy traversal of the message structure in Swift simply by checking enum cases.
*/
public enum PlainTextOnly: FlatCodable {
	/// The wrapped content is [a plain text object](https://api.slack.com/reference/block-kit/composition-objects#text)
	case plainText(PlainText)


	public enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	public enum CodingValue: String, ShadowEnum {
		case plainText = "plain_text"
	}
}


/// Object representing the contents of [a Block Kit image block]https://api.slack.com/reference/block-kit/blocks#image)
public struct Image: Codable {
	/// URL at which the image contents are stored
	public let url: String
	/// Alternate text summary of the image
	public let alternateText: String

	/**
	Create an instance from the component properties

	- Parameters:
		- url: URL at which the image contents are stored
		- alternateText: alternate text summary of the image
	*/
	public init(url: String, alternateText: String) {
		self.url = url
		self.alternateText = alternateText
	}


	internal enum CodingKeys: String, CodingKey {
		case url           = "image_url"
		case alternateText = "alt_text"
	}
}

public struct Mrkdwn: Codable {
	/// Mrkdwn-formatted text content
	let text: String

	/**
	Whether to auto-parse links (URLs, channel references, username mentions) (`false`) or not (`true`)

	When `nil`, Slack interprets this as `false`.
	*/
	let interpretLinksVerbatim: Bool?


	enum CodingKeys: String, CodingKey {
		case text
		case interpretLinksVerbatim = "verbatim"
	}
}

public struct PlainText: Codable {
	/// Plain text content
	let text: String

	/**
	Whether to auto-parse colon-escaped emoji (for example, `:tada:`) (`true`) or not (`false)`)

	When `nil`, Slack interprets this as `true`.
	*/
	let convertEscapedEmoji: Bool?


	enum CodingKeys: String, CodingKey {
		case text
		case convertEscapedEmoji = "emoji"
	}
}
