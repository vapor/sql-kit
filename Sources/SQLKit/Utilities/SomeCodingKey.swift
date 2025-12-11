/// A straightforward implementation of `CodingKey`, used to represent arbitrary keys.
///
/// This type is a simple helper, compensating for the inability to depend on the presence
/// of [`CodingKeyRepresentable`] (introduced in Swift 5.6 and tagged with a
/// macOS 12.3/iOS 15.4 availability requirement) without a major version bump.
///
/// > Note: Both the purpose and implementation of this type are almost exactly identical
/// > to those of the standard library's internal [`_DictionaryCodingKey`] type.
///
/// ![Quotation](codingkey-quotation)
///
/// [`_DictionaryCodingKey`]: https://github.com/swiftlang/swift/blob/swift-6.0-RELEASE/stdlib/public/core/Codable.swift#L6124
/// [`CodingKeyRepresentable`]: https://developer.apple.com/documentation/swift/codingkeyrepresentable
public struct SomeCodingKey: CodingKey, Hashable, Sendable {
    // See `CodingKey.stringValue`.
    public let stringValue: String
    
    // See `CodingKey.intValue`.
    public let intValue: Int?

    // See `CodingKey.init(stringValue:)`.
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    // See `CodingKey.init(intValue:)`.
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
