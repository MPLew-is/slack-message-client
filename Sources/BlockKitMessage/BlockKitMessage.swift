struct Message: Codable {
	let blocks: [Block]
}

enum Block: FlatCodable {
	enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	case header(Header)
	case section(Section)
	case context(Context)

	enum CodingValue: String, ShadowEnum {
		case header
		case section
		case context
	}
}


struct Header: Codable {
	let id: String?

	let text: PlainTextOnly


	init(_ text: PlainText, id: String? = nil) {
		self.id = id
		self.text = .plainText(text)
	}
}

struct Section: Codable {
	let id: String?

	let text: Text


	init(mrkdwn: Mrkdwn, id: String? = nil) {
		self.id = id
		self.text = .mrkdwn(mrkdwn)
	}

	init(plainText: PlainText, id: String? = nil) {
		self.id = id
		self.text = .plainText(plainText)
	}
}

struct Context: Codable {
	let id: String?

	let elements: [ContextElement]
}


enum ContextElement: FlatCodable {
	enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	case plainText(PlainText)
	case mrkdwn(Mrkdwn)
	case image(Image)

	enum CodingValue: String, ShadowEnum {
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


struct Image: Codable {
	let url: String
	let alternateText: String

	enum CodingKeys: String, CodingKey {
		case url           = "image_url"
		case alternateText = "alt_text"
	}
}

struct Mrkdwn: Codable {
	let text: String

	// When `nil`, Slack interprets this as `false`.
	let interpretLinksVerbatim: Bool?


	enum CodingKeys: String, CodingKey {
		case text
		case interpretLinksVerbatim = "verbatim"
	}
}

struct PlainText: Codable {
	let text: String

	// When `nil`, Slack interprets this as `true`.
	let convertEscapedEmoji: Bool?


	enum CodingKeys: String, CodingKey {
		case text
		case convertEscapedEmoji = "emoji"
	}
}
