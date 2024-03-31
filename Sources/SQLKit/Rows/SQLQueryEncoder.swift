public struct SQLQueryEncoder {
    public enum NilEncodingStrategy {
        /// Skips nilable columns with nil values during encoding.
        case `default`
        /// Encodes nilable columns with nil values as nil. Useful when using `SQLInsertBuilder` to insert `Codable` models without Fluent
        case asNil
    }

    public enum KeyEncodingStrategy {
        /// A key encoding strategy that doesn't change key names during encoding.
        case useDefaultKeys
        /// A key encoding strategy that converts camel-case keys to snake-case keys.
        case convertToSnakeCase
        case custom(([any CodingKey]) -> any CodingKey)
    }

    public var prefix: String? = nil
    public var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
    public var nilEncodingStrategy: NilEncodingStrategy = .default

    public init() {
        self.init(prefix: nil, keyEncodingStrategy: .useDefaultKeys, nilEncodingStrategy: .default)
    }
    
    init(prefix: String?, keyEncodingStrategy: KeyEncodingStrategy, nilEncodingStrategy: NilEncodingStrategy) {
        self.prefix = prefix
        self.keyEncodingStrategy = keyEncodingStrategy
        self.nilEncodingStrategy = nilEncodingStrategy
    }

    public func encode<E: Encodable>(_ encodable: E) throws -> [(String, any SQLExpression)] {
        let encoder = _Encoder(options: options)
        try encodable.encode(to: encoder)
        return encoder.row
    }

    fileprivate struct _Options {
        let prefix: String?
        let keyEncodingStrategy: KeyEncodingStrategy
        let nilEncodingStrategy: NilEncodingStrategy
    }

    /// The options set on the top-level decoder.
    fileprivate var options: _Options {
        _Options(
            prefix: self.prefix,
            keyEncodingStrategy: self.keyEncodingStrategy,
            nilEncodingStrategy: self.nilEncodingStrategy)
    }
}

private final class _Encoder: Encoder {
    fileprivate let options: SQLQueryEncoder._Options
    var row: [(String, any SQLExpression)] = []
    var codingPath: [any CodingKey] { [] }
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    init(options: SQLQueryEncoder._Options) { self.options = options }

    func container<Key: CodingKey>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        switch options.nilEncodingStrategy {
        case .asNil: return KeyedEncodingContainer(_NilColumnKeyedEncoder(encoder: self))
        case .default: return KeyedEncodingContainer(_KeyedEncoder(encoder: self))
        }
    }
    func unkeyedContainer() -> any UnkeyedEncodingContainer { fatalError() }
    func singleValueContainer() -> any SingleValueEncodingContainer { fatalError() }

    struct _NilColumnKeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var codingPath: [any CodingKey] { self.encoder.codingPath }
        let encoder: _Encoder
        func column(for key: Key) -> String {
            var encodedKey = key.stringValue
            switch self.encoder.options.keyEncodingStrategy {
            case .useDefaultKeys: break
            case .convertToSnakeCase: encodedKey = _convertToSnakeCase(encodedKey)
            case .custom(let customKeyEncodingFunc): encodedKey = customKeyEncodingFunc([key]).stringValue
            }
            if let prefix = self.encoder.options.prefix { return prefix + encodedKey } else { return encodedKey }
        }
        mutating func encodeNil(forKey key: Key) throws { self.encoder.row.append((self.column(for: key), SQLLiteral.null)) }
        mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            self.encoder.row.append((self.column(for: key), (value as? SQLExpression) ?? SQLBind(value)))
        }
        mutating func _encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
            if let value = value { try encode(value, forKey: key) } else { try encodeNil(forKey: key) }
        }
        mutating func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key)}
        mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
        mutating func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: Key) -> KeyedEncodingContainer<N> { fatalError() }
        mutating func nestedUnkeyedContainer(forKey: Key) -> any UnkeyedEncodingContainer { fatalError() }
        mutating func superEncoder() -> any Encoder { self.encoder }
        mutating func superEncoder(forKey key: Key) -> any Encoder { self.encoder }
    }
    struct _KeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var codingPath: [CodingKey] { self.encoder.codingPath }
        let encoder: _Encoder
        func column(for key: Key) -> String {
            var encodedKey = key.stringValue
            switch self.encoder.options.keyEncodingStrategy {
            case .useDefaultKeys: break
            case .convertToSnakeCase: encodedKey = _convertToSnakeCase(encodedKey)
            case .custom(let customKeyEncodingFunc): encodedKey = customKeyEncodingFunc([key]).stringValue
            }
            if let prefix = self.encoder.options.prefix { return prefix + encodedKey } else { return encodedKey }
        }
        mutating func encodeNil(forKey key: Key) throws { self.encoder.row.append((self.column(for: key), SQLLiteral.null)) }
        mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            self.encoder.row.append((self.column(for: key), (value as? SQLExpression) ?? SQLBind(value)))
        }
        mutating func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: Key) -> KeyedEncodingContainer<N> { fatalError() }
        mutating func nestedUnkeyedContainer(forKey: Key) -> any UnkeyedEncodingContainer { fatalError() }
        mutating func superEncoder() -> any Encoder { self.encoder }
        mutating func superEncoder(forKey: Key) -> any Encoder { self.encoder }
    }
}

private extension _Encoder {
    /// This is a custom implementation which does not require Foundation as opposed to the one at which needs CharacterSet from Foundation https://github.com/apple/swift/blob/master/stdlib/public/Darwin/Foundation/JSONEncoder.swift
    ///
    /// Provide a custom conversion to the key in the encoded JSON from the keys specified by the encoded types.
    /// The full path to the current encoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before encoding.
    /// If the result of the conversion is a duplicate key, then only one value will be present in the result.
    static func _convertToSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }
        enum Status { case uppercase, lowercase }
        var status = Status.lowercase, snakeCasedString = "", i = stringKey.startIndex
        while i < stringKey.endIndex {
            let nextIndex = stringKey.index(after: i)
            if stringKey[i].isUppercase {
                switch status {
                case .uppercase where nextIndex < stringKey.endIndex && stringKey[nextIndex].isLowercase,
                     .lowercase where i != stringKey.startIndex:
                    snakeCasedString.append("_")
                default: break
                }
                status = .uppercase
                snakeCasedString.append(stringKey[i].lowercased())
            } else {
                status = .lowercase
                snakeCasedString.append(stringKey[i])
            }
            i = nextIndex
        }
        return snakeCasedString
    }
}
