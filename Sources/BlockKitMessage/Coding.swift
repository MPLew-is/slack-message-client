// Actually provide the needed implementations to get the correct encoding structure, which mostly have to do with packing and unpacking enum cases/associated values for use by the `FlatCodingWrapper` default implementations.


extension Block: CaseNameReflectable {}

extension Block: FlatCodingWrapper {
	public init(from shadow: CodingValue, with decoder: Decoder) throws {
		switch shadow {
			case .header:
				self = .header(try .init(from: decoder))

			case .section:
				self = .section(try .init(from: decoder))

			case .context:
				self = .context(try .init(from: decoder))
		}
	}


	public init?(wrapping value: Codable) {
		switch value {
			case let value as Header:
				self = .header(value)

			case let value as Section:
				self = .section(value)

			case let value as Context:
				self = .context(value)

			default:
				return nil
		}
	}

	public var wrappedValue: Codable {
		switch self {
			case .header(let value):
				return value

			case .section(let value):
				return value

			case .context(let value):
				return value
		}
	}
}


extension ContextElement: CaseNameReflectable {}

extension ContextElement: FlatCodingWrapper {
	public init(from shadow: CodingValue, with decoder: Decoder) throws {
		switch shadow {
			case .plainText:
				self = .plainText(try .init(from: decoder))

			case .mrkdwn:
				self = .mrkdwn(try .init(from: decoder))

			case .image:
				self = .image(try .init(from: decoder))
		}
	}


	public init?(wrapping value: Codable) {
		switch value {
			case let value as PlainText:
				self = .plainText(value)

			case let value as Mrkdwn:
				self = .mrkdwn(value)

			case let value as Image:
				self = .image(value)

			default:
				return nil
		}
	}

	public var wrappedValue: Codable {
		switch self {
			case .plainText(let value):
				return value

			case .mrkdwn(let value):
				return value

			case .image(let value):
				return value
		}
	}
}


extension Text: CaseNameReflectable {}

extension Text: FlatCodingWrapper {
	init(from shadow: CodingValue, with decoder: Decoder) throws {
		switch shadow {
			case .plainText:
				self = .plainText(try .init(from: decoder))

			case .mrkdwn:
				self = .mrkdwn(try .init(from: decoder))
		}
	}


	init?(wrapping value: Codable) {
		switch value {
			case let value as PlainText:
				self = .plainText(value)

			case let value as Mrkdwn:
				self = .mrkdwn(value)

			default:
				return nil
		}
	}

	var wrappedValue: Codable {
		switch self {
			case .plainText(let value):
				return value

			case .mrkdwn(let value):
				return value
		}
	}
}


extension PlainTextOnly: CaseNameReflectable {}

extension PlainTextOnly: FlatCodingWrapper {
	init(from shadow: CodingValue, with decoder: Decoder) throws {
		switch shadow {
			case .plainText:
				self = .plainText(try .init(from: decoder))
		}
	}


	init?(wrapping value: Codable) {
		switch value {
			case let value as PlainText:
				self = .plainText(value)

			default:
				return nil
		}
	}

	var wrappedValue: Codable {
		switch self {
			case .plainText(let value):
				return value
		}
	}
}
