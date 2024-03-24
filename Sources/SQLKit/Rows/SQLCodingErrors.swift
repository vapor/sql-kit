/// Errors raised by ``SQLRowDecoder`` and ``SQLQueryEncoder``.
enum SQLCodingError: Error, CustomStringConvertible, Sendable {
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
    var description: String {
        switch self {
        case .unsupportedOperation(let operation, codingPath: let path):
            return "Value at path '\(path.map(\.stringValue).joined(separator: "."))' attempted an unsupported operation: '\(operation)'"
        }
    }
}

extension Error where Self == SQLCodingError {
    /// Yield a ``SQLCodingError/unsupportedOperation(_:codingPath:)`` for the given operation and path.
    static func invalid(_ function: String = #function, at path: [any CodingKey]) -> Self {
        .unsupportedOperation(function, codingPath: path)
    }
}

/// A `CodingKey` which can't be successfully initialized and never holds a value.
///
/// Used as a placeholder by ``FailureEncoder``.
struct NeverKey: CodingKey {
    // See `CodingKey.stringValue`.
    let stringValue: String = ""
    
    // See `CodingKey.intValue`.
    let intValue: Int? = nil
    
    // See `CodingKey.init(stringValue:)`.
    init?(stringValue: String) {
        nil
    }
    
    // See `CodingKey.init?(intValue:)`.
    init?(intValue: Int) {
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
struct FailureEncoder<K: CodingKey>: Encoder, KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
    let error: any Error
    init(_ error: any Error)                         { self.error = error }
    init(_ error: any Error) where K == NeverKey     { self.error = error }
    var codingPath: [any CodingKey]                  { [] }
    var userInfo: [CodingUserInfoKey: Any]           { [:] }
    var count: Int                                   { 0 }
    func encodeNil() throws                          { throw self.error }
    func encodeNil(forKey: K) throws                 { throw self.error }
    func encode(_: some Encodable) throws            { throw self.error }
    func encode(_: some Encodable, forKey: K) throws { throw self.error }
    func superEncoder() -> any Encoder               { self }
    func superEncoder(forKey: K) -> any Encoder      { self }
    func unkeyedContainer() -> any UnkeyedEncodingContainer                { self }
    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer          { self }
    func nestedUnkeyedContainer(forKey: K) -> any UnkeyedEncodingContainer { self }
    func singleValueContainer() -> any SingleValueEncodingContainer        { self }
    func container<N: CodingKey>(keyedBy: N.Type = N.self) -> KeyedEncodingContainer<N>         { .init(FailureEncoder<N>(self.error)) }
    func nestedContainer<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N>            { self.container() }
    func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: K) -> KeyedEncodingContainer<N> { self.container() }
}

extension Encoder where Self == FailureEncoder<NeverKey> {
    /// Yield a ``FailureEncoder`` which throws ``SQLCodingError/unsupportedOperation(_:codingPath:)`` from a context
    /// which expects an `Encoder`.
    static func invalid(_ f: String = #function, at: [any CodingKey]) -> Self {
        .init(.invalid(f, at: at))
    }
}

extension KeyedEncodingContainer {
    /// Yield a ``FailureEncoder`` which throws ``SQLCodingError/unsupportedOperation(_:codingPath:)`` from a context
    /// which expects a `KeyedEncodingContainer`.
    static func invalid(_ f: String = #function, at: [any CodingKey]) -> Self {
        .init(FailureEncoder<Key>(.invalid(f, at: at)))
    }
}

extension UnkeyedEncodingContainer where Self == FailureEncoder<NeverKey> {
    /// Yield a ``FailureEncoder`` which throws ``SQLCodingError/unsupportedOperation(_:codingPath:)`` from a context
    /// which expects an `UnkeyedEncodingContainer`.
    static func invalid(_ f: String = #function, at: [any CodingKey]) -> Self {
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
struct FakeSendable<E: Encodable>: Encodable, @unchecked Sendable {
    let value: E

    init(_ value: E) {
        self.value = value
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.value)
    }
}
