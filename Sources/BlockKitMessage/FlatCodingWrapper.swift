/**
An enum whose String case name can be accessed via reflection using the `caseName` instance property

Only designed to be conformed to by enums, with undefined behavior if implemented by other object types.

Derived from: https://www.avanderlee.com/swift/reflection-how-mirror-works/
*/
protocol CaseNameReflectable {
	/// Name of the enum instance's case
	var caseName: String { get }
}
extension CaseNameReflectable {
	var caseName: String {
		let mirror = Mirror(reflecting: self)
		guard let caseName = mirror.children.first?.label else {
			return "\(self)"
		}
		return caseName
	}
}


/**
An enum assumed to only have a single case, with that case (no matter its name) accessible via the `onlyCase` static property

If the conforming enum _does_ happen to have multiple cases, the first-defined case (as determined by the `CaseIterable` implementation) will be returned.
*/
protocol SingleCasedEnum: CaseIterable {
	/// An instance of the only case defined by the enum
	static var onlyCase: Self { get }
}
extension SingleCasedEnum {
	static var onlyCase: Self {
		return Self.allCases.first!
	}
}


/**
An enum assumed to have the same set of case names as another enum

The primary utility of this protocol is to allow another enum to store some associated data about the primary one, such as `CodingKey` mappings on an enum with an associated value.
*/
protocol ShadowEnum: Codable, RawRepresentable, CaseIterable, CaseNameReflectable {
	/**
	Create an instance of this shadow enum from an instance of the other.

	- Parameters:
		- shadowing: an instance of the "parent" enum to create a matching instance of this enum from
	*/
	init?(shadowing: CaseNameReflectable)
}
extension ShadowEnum {
	// Define a helper computed property for indexing the cases by name, since we can't store real properties in extensions.
	// This does result in rebuilding the `Dict` every time this enum is initialized, but there's no other way we can really provide a default implementation.
	private static var casesByName: [String: Self] {
		return Self.allCases.reduce(into: [String: Self]()) { result, element in
			result[element.caseName] = element
		}
	}

	init?(shadowing other: CaseNameReflectable) {
		guard let newSelf = Self.casesByName[other.caseName] else {
			return nil
		}

		self = newSelf
	}
}


/**
Shortcut protocol for ease of use in conformers of `FlatCodable`, combining `SingleCasedEnum` and `CodingKey`
*/
protocol SingleValuedCodingKey: SingleCasedEnum, CodingKey {}

/**
An object that is intended to have its single key-value pair encoded inline with another associated object

For instance, an enum with an associated value would normally have the associated value encoded as a sub-field, but objects conforming to this protocol are intended to have all values flattened together.

This protocol doesn't actually implement any of those features, it is simply for convenience to allow the `CodingKeys` and `CodingValue` to be specified at the declaration site while still allowing the rest of `FlatCodingWrapper` to be implemented in an extension.
Effectively, this is just here so the compiler can throw an error if users haven't provided all the necessary information that semantically belongs at the declaration site.

- Example:
```swift
enum FlatCoded: CaseNameReflectable, FlatCodingWrapper {
	enum CodingKeys: String, SingleValuedCodingKey {
		case type
	}

	enum CodingValues: String, ShadowEnum {
		case string
		case integer = "int"
	}


	struct StringValue: Codable {
		let string: String
	}

	struct IntegerValue: Codable {
		enum CodingKeys: String, CodingKey {
			case integer = "int"
		}

		let integer: Int
	}

	case string(StringValue)
	case integer(IntegerValue)
}
```

The above is intended to produce objects like:
```json
{
	"type": "string",
	"string": "foo"
}
```
and:
```json
{
	"type": "int",
	"int": 3
}
````
*/
protocol FlatCodable: Codable {
	associatedtype CodingKeys: SingleValuedCodingKey
	associatedtype CodingValue: Codable
}


/**
An object that has its single key-value pair encoded inline with another associated object

For instance, an enum with an associated value would normally have the associated value encoded as a sub-field, but objects conforming to this protocol have all values flattened together.

This protocol actually implements all of the encoding and decoding discussed in `FlatCodable`, but its requirements can be implemented in another extension for separation of concerns.
*/
protocol FlatCodingWrapper: FlatCodable {
	/// Value to be used for the "tag" encoding the value of this wrapper
	var codingValue: CodingValue { get }

	/**
	Having already decoded which value this wrapper should take, continue decoding the wrapped value.

	- Parameters:
		- from:    already-decoded value for the single key-value pair this wrapper was encoded as
		- decoder: Codable `Decoder` to use to parse the wrapped value

	- Throws: only rethrows errors produced in normal Codable decoding
	*/
	init(from: CodingValue, with: Decoder) throws


	/// Raw value wrapped by this container
	var wrappedValue: Codable { get }

	/**
	Initialize an instance of this wrapper from an instance of the wrapped value.

	This wrapper should be able to unambiguously initialize itself given _only_ an instance of the wrapped value (and then determine its properties from that value's type or property values).

	- Parameters:
		- wrapping: value to wrap in this container
	*/
	init?(wrapping: Codable)
}

// Give default implementations for encoding and decoding, since we can do so with the protocol requirements.
extension FlatCodingWrapper {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.codingValue, forKey: .onlyCase)
		try self.wrappedValue.encode(to: encoder)
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let shadow = try container.decode(CodingValue.self, forKey: .onlyCase)
		try self.init(from: shadow, with: decoder)
	}
}

// When the value we're encoding is an enum with a shadow coding value, we can provide a default implementation for the coding value for the wrapper based on the `CaseNameReflectable` implementation.
extension FlatCodingWrapper where Self: CaseNameReflectable, CodingValue: ShadowEnum {
	var codingValue: CodingValue {
		return .init(shadowing: self)!
	}
}
