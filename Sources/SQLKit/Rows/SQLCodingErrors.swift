/// Errors raised by ``SQLRowDecoder`` and ``SQLQueryEncoder``.
@_spi(CodableUtilities)
public enum SQLCodingError: Error, CustomStringConvertible, Sendable {
    /// An attempt was made to invoke one of the forbidden coding methods, or a restricted coding method in an
    /// unsupported context, during query encoding or row decoding.
    ///
    /// The following methods are always usupported:
    ///
    /// - `Encoder.unkeyedContainer()`
    /// - `Decoder.unkeyedContainer()`
    /// - `KeyedEncodingContainer.nestedContainer(keyedBy:forKey:)`
    /// - `KeyedEncodingContainer.nestedUnkeyedContainer(forKey:)`
    /// - `KeyedEncodingContainer.superEncoder()`
    /// - `KeyedDecodingContainer.nestedContainer(keyedBy:forKey:)`
    /// - `KeyedDecodingContainer.nestedUnkeyedContainer(forKey:)`
    /// - `KeyedDecodingContainer.superDecoder()`
    /// - Any use of `UnkeyedEncodingContainer`
    /// - Any use of `UnkeyedDecodingContainer`
    ///
    /// The following methods are unsupported unless the current coding path is empty:
    ///
    /// - `Encoder.container(keyedBy:)`
    /// - `Decoder.container(keyedBy:)`
    /// - `KeyedEncodingContainer.superEncoder(forKey:)`
    /// - `KeyedDecodingContainer.superDecoder(forKey:)`
    case unsupportedOperation(String, codingPath: [any CodingKey])
    
    // See `CustomStringConvertible.description`.
    public var description: String {
        switch self {
        case .unsupportedOperation(let operation, codingPath: let path):
            return "Value at path '\(path.map(\.stringValue).joined(separator: "."))' attempted an unsupported operation: '\(operation)'"
        }
    }
}

@_spi(CodableUtilities)
extension Error where Self == SQLCodingError {
    /// Yield a ``SQLCodingError/unsupportedOperation(_:codingPath:)`` for the given operation and path.
    public static func invalid(_ function: String = #function, at path: [any CodingKey]) -> Self {
        .unsupportedOperation(function, codingPath: path)
    }
}

/// A `CodingKey` which can't be successfully initialized and never holds a value.
///
/// Used as a placeholder by ``FailureEncoder``.
@_spi(CodableUtilities)
public struct NeverKey: CodingKey {
    // See `CodingKey.stringValue`.
    public let stringValue: String = ""
    
    // See `CodingKey.intValue`.
    public let intValue: Int? = nil
    
    // See `CodingKey.init(stringValue:)`.
    public init?(stringValue: String) {
        nil
    }
    
    // See `CodingKey.init?(intValue:)`.
    public init?(intValue: Int) {
        nil
    }
}

/// An encoder which throws a predetermined error from every method which can throw and recurses back to itself from
/// everything else.
///
/// This type functions as a workaround for the inability of encoders to throw errors from various places that it
/// would otherwise be useful to throw errors from.
///
/// > Besides: It's still better than calling `fatalError()`.
@_spi(CodableUtilities)
public struct FailureEncoder<K: CodingKey>: Encoder, KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
    let error: any Error
    public init(_ error: any Error)                         { self.error = error }
    public init(_ error: any Error) where K == NeverKey     { self.error = error }
    public var codingPath: [any CodingKey]                  { [] }
    public var userInfo: [CodingUserInfoKey: Any]           { [:] }
    public var count: Int                                   { 0 }
    public func encodeNil() throws                          { throw self.error }
    public func encodeNil(forKey: K) throws                 { throw self.error }
    public func encode(_: some Encodable) throws            { throw self.error }
    public func encode(_: some Encodable, forKey: K) throws { throw self.error }
    public func superEncoder() -> any Encoder               { self }
    public func superEncoder(forKey: K) -> any Encoder      { self }
    public func unkeyedContainer() -> any UnkeyedEncodingContainer                { self }
    public func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer          { self }
    public func nestedUnkeyedContainer(forKey: K) -> any UnkeyedEncodingContainer { self }
    public func singleValueContainer() -> any SingleValueEncodingContainer        { self }
    public func container<N: CodingKey>(keyedBy: N.Type = N.self) -> KeyedEncodingContainer<N>         { .init(FailureEncoder<N>(self.error)) }
    public func nestedContainer<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N>            { self.container() }
    public func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: K) -> KeyedEncodingContainer<N> { self.container() }
}

@_spi(CodableUtilities)
extension Encoder where Self == FailureEncoder<NeverKey> {
    /// Yield a ``FailureEncoder`` which throws ``SQLCodingError/unsupportedOperation(_:codingPath:)`` from a context
    /// which expects an `Encoder`.
    public static func invalid(_ f: String = #function, at: [any CodingKey]) -> Self {
        .init(.invalid(f, at: at))
    }
}

@_spi(CodableUtilities)
extension KeyedEncodingContainer {
    /// Yield a ``FailureEncoder`` which throws ``SQLCodingError/unsupportedOperation(_:codingPath:)`` from a context
    /// which expects a `KeyedEncodingContainer`.
    public static func invalid(_ f: String = #function, at: [any CodingKey]) -> Self {
        .init(FailureEncoder<Key>(.invalid(f, at: at)))
    }
}

@_spi(CodableUtilities)
extension UnkeyedEncodingContainer where Self == FailureEncoder<NeverKey> {
    /// Yield a ``FailureEncoder`` which throws ``SQLCodingError/unsupportedOperation(_:codingPath:)`` from a context
    /// which expects an `UnkeyedEncodingContainer`.
    public static func invalid(_ f: String = #function, at: [any CodingKey]) -> Self {
        .init(.invalid(f, at: at))
    }
}

extension DecodingError {
    /// Return the same error with its context modified to have the given coding path prepended.
    func under(path: [any CodingKey]) -> Self {
        switch self {
        case let .valueNotFound(type, context):
            return .valueNotFound(type, context.with(prefix: path))
        case let .dataCorrupted(context):
            return .dataCorrupted(context.with(prefix: path))
        case let .typeMismatch(type, context):
            return .typeMismatch(type, context.with(prefix: path))
        case let .keyNotFound(key, context):
            return .keyNotFound(key, context.with(prefix: path))
        @unknown default: return self
        }
    }
}

extension DecodingError.Context {
    /// Return the same context with the given coding path prepended.
    fileprivate func with(prefix: [any CodingKey]) -> Self {
        .init(
            codingPath: prefix + self.codingPath,
            debugDescription: self.debugDescription,
            underlyingError: self.underlyingError
        )
    }
}

/// A helper used to pass `Encodable` but non-`Sendable` values provided by the `Encoder` API to
/// ``SQLBind/init(_:)``, which requires `Sendable` conformance, without warnings.
///
/// Note that this more often than not ends up wrapping values of types that _are_ in fact `Sendable`,
/// but that can't be treated as such because of the limitations of `Codable`'s design and the inability
/// to check for `Sendable` conformance at runtime.
struct FakeSendable<E: Encodable>: Encodable, @unchecked Sendable {
    /// The underyling non-`Sendable` value.
    let value: E
    
    /// Trivial initializer.
    init(_ value: E) {
        self.value = value
    }

    // See `Encodable.encode(to:)`.
    func encode(to encoder: any Encoder) throws {
        /// It is important to encode the desired value into a single-value container rather than invoking its
        /// `encode(to:)` method directly, so that any type-specific logic within the encoder itself (such as
        /// that found in `JSONEncoder` for `Date`, `Data`, etc.) takes effect. In essence, the encoder must have
        /// the opportunity to intercept the value and its type. With `SQLQueryEncoder`, this makes the difference
        /// between `FakeSendable` being fully transparent versus not.
        var container = encoder.singleValueContainer()
        
        try container.encode(self.value)
    }
}
