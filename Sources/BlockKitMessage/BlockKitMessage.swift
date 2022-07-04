public struct Message: Codable {
	let blocks: [Block]
}

public enum Block: FlatCodable {
	public enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	case header(Header)
	case section(Section)
	case context(Context)

	public enum CodingValue: String, ShadowEnum {
		case header
		case section
		case context
	}
}


public struct Header: Codable {
	let id: String?

	let text: PlainTextOnly
}

public struct Section: Codable {
	let id: String?

	let text: Text
}

public struct Context: Codable {
	let id: String?

	let elements: [ContextElement]
}


public enum ContextElement: FlatCodable {
	public enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	case plainText(PlainText)
	case mrkdwn(Mrkdwn)
	case image(Image)

	public enum CodingValue: String, ShadowEnum {
		case plainText = "plain_text"
		case mrkdwn
		case image
	}
}


enum Text: FlatCodable {
	enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	case plainText(PlainText)
	case mrkdwn(Mrkdwn)

	enum CodingValue: String, ShadowEnum {
		case plainText = "plain_text"
		case mrkdwn
	}
}

enum PlainTextOnly: FlatCodable {
	enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	case plainText(PlainText)

	enum CodingValue: String, ShadowEnum {
		case plainText = "plain_text"
	}
}


public struct Image: Codable {
	let url: String
	let alternateText: String

	enum CodingKeys: String, CodingKey {
		case url           = "image_url"
		case alternateText = "alt_text"
	}


	public init(url: String, alternateText: String) {
		self.url = url
		self.alternateText = alternateText
	}
}

public struct Mrkdwn: Codable {
	let text: String

	// When `nil`, Slack interprets this as `false`.
	let interpretLinksVerbatim: Bool?


	enum CodingKeys: String, CodingKey {
		case text
		case interpretLinksVerbatim = "verbatim"
	}
}

public struct PlainText: Codable {
	let text: String

	// When `nil`, Slack interprets this as `true`.
	let convertEscapedEmoji: Bool?


	enum CodingKeys: String, CodingKey {
		case text
		case convertEscapedEmoji = "emoji"
	}
}
