/// Errors raised by ``SQLRowDecoder`` and ``SQLQueryEncoder``.
enum SQLCodingError: Error, CustomStringConvertible, CustomDebugStringConvertible, Sendable {
    /// An attempt was made to invoke one of the "nested container" methods during encoding or decoding.
    ///
    /// The following methods are not supported for row/query coding:
    /// - `KeyedEncodingContainer.nestedContainer(keyedBy:forKey:)`
    /// - `KeyedEncodingContainer.nestedUnkeyedContainer(forKey:)`
    /// - `KeyedEncodingContainer.superEncoder()`
    /// - `KeyedEncodingContainer.superEncoder(forKey:)`
    /// - `KeyedDecodingContainer.nestedContainer(keyedBy:forKey:)`
    /// - `KeyedDecodingContainer.nestedUnkeyedContainer(forKey:)`
    /// - `KeyedDecodingContainer.superDecoder()`
    /// - `KeyedDecodingContainer.superDecoder(forKey:)`
    /// - `UnkeyedEncodingContainer.nestedContainer(keyedBy:)`
    /// - `UnkeyedEncodingContainer.nestedUnkeyedContainer()`
    /// - `UnkeyedEncodingContainer.superEncoder()`
    /// - `UnkeyedDecodingContainer.nestedContainer(keyedBy:)`
    /// - `UnkeyedDecodingContainer.nestedUnkeyedContainer()`
    /// - `UnkeyedDecodingContainer.superDecoder()`
    case nesting(method: String, codingPath: [any CodingKey])
    
    /// An unkeyed container was requested from a top-level encoder or decoder.
    ///
    /// This typically indicates an attempt to encode or decode a type which is represented as an array,
    /// which is not supported for row/query coding.
    case unkeyedContainer(codingPath: [any CodingKey])
    
    /// A single-value container was requested from a top-level encoder or decoder.
    ///
    /// This typically indicates an attempt to encode or decode a type which is represented as a scalar value,
    /// which is not supported for row/query coding.
    case singleValueContainer(codingPath: [any CodingKey])
    
    static func error(for function: String, at codingPath: [any CodingKey]) -> SQLCodingError {
        switch function {
        case "unkeyedContainer()":
            return .unkeyedContainer(codingPath: codingPath)
        case "singleValueContainer()":
            return .singleValueContainer(codingPath: codingPath)
        case "nestedContainer(keyedBy:forKey:)", "nestedContainer(keyedBy:)",
             "nestedUnkeyedContainer(forKey:)", "nestedUnkeyedContainer()",
             "superEncoder()", "superDecoder()", "superEncoder(forKey:)", "superDecoder(forKey:)",
             _:
            return .nesting(method: function, codingPath: codingPath)
        }
    }
    
    // See `CustomStringConvertible.description`.
    var description: String {
        switch self {
        case .nesting(method: let method, codingPath: let codingPath):
            return "Value at path '\(codingPath.map(\.stringValue).joined(separator: "."))' used an unsupported decoding method: '\(method)'"
        case .unkeyedContainer(codingPath: let codingPath):
            return "Value at path '\(codingPath.map(\.stringValue).joined(separator: "."))' cannot be decoded as a top-level array"
        case .singleValueContainer(codingPath: let codingPath):
            return "Value at path '\(codingPath.map(\.stringValue).joined(separator: "."))' cannot be decoded as a scalar type"
        }
    }
    
    // See `CustomDebugStringConvertible.debugDescription`.
    var debugDescription: String {
        self.description
    }
}

extension Error where Self == SQLCodingError {
    static func invalid(f: String = #function, in c: some Decoder) -> Self                                             { self.error(for: f, at: c.codingPath) }
    static func invalid(f: String = #function, in c: some Encoder) -> Self                                             { self.error(for: f, at: c.codingPath) }
    static func invalid(f: String = #function, in c: some KeyedEncodingContainerProtocol, key: some CodingKey) -> Self { self.error(for: f, at: c.codingPath + [key]) }
    static func invalid(f: String = #function, in c: some KeyedDecodingContainerProtocol, key: some CodingKey) -> Self { self.error(for: f, at: c.codingPath + [key]) }
    static func invalid(f: String = #function, in c: some UnkeyedEncodingContainer) -> Self                            { self.error(for: f, at: c.codingPath) }
    static func invalid(f: String = #function, in c: some UnkeyedDecodingContainer) -> Self                            { self.error(for: f, at: c.codingPath) }
}

/// A `CodingKey` which can't be successfully initialized and never holds a valid value.
///
/// Used as a placeholder by ``FailureEncoder``.
@usableFromInline
struct NeverCodingKey: CodingKey {
    @inlinable var stringValue: String { "" }
    @inlinable var intValue: Int? { nil }
    @inlinable init?(stringValue: String) { return nil }
    @inlinable init?(intValue: Int) { return nil }
}

/// This is a workaround for the inability of encoders to throw errors in various places. It's still better than fatalError()ing.
@usableFromInline
struct FailureEncoder<K: CodingKey, E: Swift.Error>: Encoder, KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
    @usableFromInline let error: E
    @inlinable init(error: E)                                                                              { self.error = error }
    @inlinable init(error: E) where K == NeverCodingKey                                                    { self.error = error }
    @inlinable var codingPath: [any CodingKey]                                                             { [] }
    @inlinable var userInfo: [CodingUserInfoKey: Any]                                                      { [:] }
    @inlinable var count: Int                                                                              { 0 }
    @inlinable func encodeNil() throws                                                                     { throw self.error }
    @inlinable func encodeNil(forKey: K) throws                                                            { throw self.error }
    @inlinable func encode(_: some Encodable) throws                                                       { throw self.error }
    @inlinable func encode(_: some Encodable, forKey: K) throws                                            { throw self.error }
    @inlinable func container<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N>                  { .init(FailureEncoder<N, E>(error: self.error)) }
    @inlinable func nestedContainer<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N>            { self.container(keyedBy: N.self) }
    @inlinable func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: K) -> KeyedEncodingContainer<N> { self.container(keyedBy: N.self) }
    @inlinable func unkeyedContainer() -> any UnkeyedEncodingContainer                                     { self }
    @inlinable func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer                               { self }
    @inlinable func nestedUnkeyedContainer(forKey: K) -> any UnkeyedEncodingContainer                      { self }
    @inlinable func superEncoder() -> any Encoder                                                          { self }
    @inlinable func superEncoder(forKey: K) -> any Encoder                                                 { self }
    @inlinable func singleValueContainer() -> any SingleValueEncodingContainer                             { self }
}

extension StringProtocol {
    /// Returns the string with its first character lowercased.
    @inlinable var decapitalized: String { self.isEmpty ? "" : "\(self[self.startIndex].lowercased())\(self.dropFirst())" }

    /// Returns the string with its first character uppercased.
    @inlinable var encapitalized: String { self.isEmpty ? "" : "\(self[self.startIndex].uppercased())\(self.dropFirst())" }

    /// Returns the string with any `snake_case` converted to `camelCase`.
    ///
    /// This is a modified version of Foundation's implementation:
    /// https://github.com/apple/swift-foundation/blob/8010dfe6b1c38cdf363c8d3d3b43d7d4f4c9987b/Sources/FoundationEssentials/JSON/JSONDecoder.swift
    var convertedFromSnakeCase: String {
        guard !self.isEmpty, let firstNonUnderscore = self.firstIndex(where: { $0 != "_" })
        else { return .init(self) }
        
        var lastNonUnderscore = self.endIndex
        repeat {
            self.formIndex(before: &lastNonUnderscore)
        } while lastNonUnderscore > firstNonUnderscore && self[lastNonUnderscore] == "_"

        let keyRange = self[firstNonUnderscore...lastNonUnderscore]
        let leading  = self[self.startIndex..<firstNonUnderscore]
        let trailing = self[self.index(after: lastNonUnderscore)..<self.endIndex]
        let words    = keyRange.split(separator: "_")
        
        guard words.count > 1 else {
            return "\(leading)\(keyRange)\(trailing)"
        }
        return "\(leading)\(([words[0].decapitalized] + words[1...].map(\.encapitalized)).joined())\(trailing)"
    }
    
    /// Returns the string with any `camelCase` converted to `snake_case`.
    ///
    /// This is a modified version of Foundation's implementation:
    /// https://github.com/apple/swift-foundation/blob/8010dfe6b1c38cdf363c8d3d3b43d7d4f4c9987b/Sources/FoundationEssentials/JSON/JSONEncoder.swift
    var convertedToSnakeCase: String {
        guard !self.isEmpty else { return .init(self) }

        var words: [Range<String.Index>] = []
        var wordStart = self.startIndex, searchIndex = self.index(after: wordStart)

        while let upperCaseIndex = self[searchIndex...].firstIndex(where: \.isUppercase) {
            words.append(wordStart..<upperCaseIndex)
            wordStart = upperCaseIndex
            guard let lowerCaseIndex = self[upperCaseIndex...].firstIndex(where: \.isLowercase) else {
                break
            }
            searchIndex = lowerCaseIndex
            if lowerCaseIndex != self.index(after: upperCaseIndex) {
                let beforeLowerIndex = self.index(before: lowerCaseIndex)
                words.append(upperCaseIndex..<beforeLowerIndex)
                wordStart = beforeLowerIndex
            }
        }
        words.append(wordStart..<self.endIndex)
        return words.map { self[$0].decapitalized }.joined(separator: "_")
    }
    
    /// A necessarily inelegant polyfill for conformance to `CodingKeyRepresentable`, due to availability problems.
    @inlinable
    var codingKeyValue: any CodingKey {
        if #available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *) {
            return String(self).codingKey
        } else {
            return SomeCodingKey(stringValue: String(self))
        }
    }
    
    /// Returns the string minus the given prefix, iff that prefix is non-`nil` and in the string.
    @inlinable
    func drop(prefix: (some StringProtocol)?) -> Self.SubSequence {
        guard let prefix, self.starts(with: prefix) else { return self[...] }
        return self.dropFirst(prefix.count)
    }
}

extension DecodingError.Context {
    /// Return a context identical to `self`, except with the given coding path prepended.
    @inlinable
    func withPrefix(_ prefixPath: [any CodingKey]) -> DecodingError.Context {
        .init(
            codingPath: prefixPath + self.codingPath,
            debugDescription: self.debugDescription,
            underlyingError: self.underlyingError
        )
    }
}

extension EncodingError.Context {
    /// Return a context identical to `self`, except with the given coding path prepended.
    @inlinable
    func withPrefix(_ prefixPath: [any CodingKey]) -> EncodingError.Context {
        .init(
            codingPath: prefixPath + self.codingPath,
            debugDescription: self.debugDescription,
            underlyingError: self.underlyingError
        )
    }
}
