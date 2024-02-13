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
    
    static func error(in function: String, at codingPath: [any CodingKey]) -> SQLCodingError {
        switch function {
        case "unkeyedContainer()":
            return .unkeyedContainer(codingPath: codingPath)
        case "singleValueContainer()":
            return .singleValueContainer(codingPath: codingPath)
        case "nestedContainer(keyedBy:forKey:)", "nestedContainer(keyedBy:)",
             "nestedUnkeyedContainer(forKey:)",  "nestedUnkeyedContainer()",
             "superEncoder(forKey:)",            "superEncoder()",
             "superDecoder(forKey:)",            "superDecoder()",
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
    static func invalid(function: String = #function, in container: some Decoder) -> Self {
        self.error(in: function, at: container.codingPath)
    }
    
    static func invalid(function: String = #function, in container: some Encoder) -> Self {
        self.error(in: function, at: container.codingPath)
    }
    
    static func invalid(function: String = #function, in container: some KeyedEncodingContainerProtocol, key: some CodingKey) -> Self {
        self.error(in: function, at: container.codingPath + [key])
    }
    
    static func invalid(function: String = #function, in container: some KeyedDecodingContainerProtocol, key: some CodingKey) -> Self {
        self.error(in: function, at: container.codingPath + [key])
    }
    
    static func invalid(function: String = #function, in container: some UnkeyedEncodingContainer) -> Self {
        self.error(in: function, at: container.codingPath)
    }
    
    static func invalid(function: String = #function, in container: some UnkeyedDecodingContainer) -> Self {
        self.error(in: function, at: container.codingPath)
    }
}

/// A `CodingKey` which can't be successfully initialized and never holds a valid value.
///
/// Used as a placeholder by ``FailureEncoder``.
struct NeverCodingKey: CodingKey {
    var stringValue: String    { "" }
    var intValue: Int?         { nil }
    init?(stringValue: String) { nil }
    init?(intValue: Int)       { nil }
}

/// This is a workaround for the inability of encoders to throw errors in various places. It's still better than fatalError()ing.
struct FailureEncoder<K: CodingKey>: Encoder, KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
    let error: any Error
    init(_ error: any Error)                                                                    { self.error = error }
    init(_ error: any Error) where K == NeverCodingKey                                          { self.error = error }
    var codingPath: [any CodingKey]                                                             { [] }
    var userInfo: [CodingUserInfoKey: Any]                                                      { [:] }
    var count: Int                                                                              { 0 }
    func encodeNil() throws                                                                     { throw self.error }
    func encodeNil(forKey: K) throws                                                            { throw self.error }
    func encode(_: some Encodable) throws                                                       { throw self.error }
    func encode(_: some Encodable, forKey: K) throws                                            { throw self.error }
    func container<N: CodingKey>(keyedBy: N.Type = N.self) -> KeyedEncodingContainer<N>         { .init(FailureEncoder<N>(self.error)) }
    func nestedContainer<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N>            { self.container() }
    func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: K) -> KeyedEncodingContainer<N> { self.container() }
    func unkeyedContainer() -> any UnkeyedEncodingContainer                                     { self }
    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer                               { self }
    func nestedUnkeyedContainer(forKey: K) -> any UnkeyedEncodingContainer                      { self }
    func superEncoder() -> any Encoder                                                          { self }
    func superEncoder(forKey: K) -> any Encoder                                                 { self }
    func singleValueContainer() -> any SingleValueEncodingContainer                             { self }
}

extension StringProtocol {
    /// Returns the string with its first character lowercased.
    @inlinable
    var decapitalized: String {
        self.isEmpty ? "" : "\(self[self.startIndex].lowercased())\(self.dropFirst())"
    }

    /// Returns the string with its first character uppercased.
    @inlinable
    var encapitalized: String {
        self.isEmpty ? "" : "\(self[self.startIndex].uppercased())\(self.dropFirst())"
    }

    /// Returns the string with any `snake_case` converted to `camelCase`.
    ///
    /// This is a modified version of Foundation's implementation:
    /// https://github.com/apple/swift-foundation/blob/8010dfe6b1c38cdf363c8d3d3b43d7d4f4c9987b/Sources/FoundationEssentials/JSON/JSONDecoder.swift
    var convertedFromSnakeCase: String {
        guard !self.isEmpty, let firstNonUnderscore = self.firstIndex(where: { $0 != "_" }) else {
            return .init(self)
        }
        
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
        guard !self.isEmpty else {
            return .init(self)
        }

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
            return SomeCodingKey(stringValue: .init(self))
        }
    }
    
    /// Returns the string minus the given prefix, iff that prefix is non-`nil` and in the string.
    @inlinable
    func drop(prefix: (some StringProtocol)?) -> Self.SubSequence {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            return prefix.map(self.trimmingPrefix(_:)) ?? self[...]
        } else {
            guard let prefix, self.starts(with: prefix) else {
                return self[...]
            }
            return self.dropFirst(prefix.count)
        }
    }
}

extension DecodingError.Context {
    /// Return a context identical to self, except with the given coding path prepended.
    @inlinable
    func with(prefix: [any CodingKey]) -> Self {
        .init(
            codingPath: prefix + self.codingPath,
            debugDescription: self.debugDescription,
            underlyingError: self.underlyingError
        )
    }
}

extension EncodingError.Context {
    /// Return a context identical to self, except with the given coding path prepended.
    @inlinable
    func with(prefix: [any CodingKey]) -> Self {
        .init(
            codingPath: prefix + self.codingPath,
            debugDescription: self.debugDescription,
            underlyingError: self.underlyingError
        )
    }
}
