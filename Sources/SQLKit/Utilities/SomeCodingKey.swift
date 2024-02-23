/// A straightforward implementation of `CodingKey`, used to represent arbitrary keys.
///
/// This type exists primarily as a helper, compensating for our inability to depend on
/// the presence of [`CodingKeyRepresentable`] (introduced in Swift 5.6 and tagged with a
/// macOS 12.3 availability requirement). Its implementation is largely identical to the
/// standard library's internal [`_DictionaryCodingKey`] type, as it serves the same purpose.
///
/// ![Quotation](codingkey-quotation)
///
/// [`_DictionaryCodingKey`]: https://github.com/apple/swift/blob/swift-5.9-RELEASE/stdlib/public/core/Codable.swift#L5509
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
