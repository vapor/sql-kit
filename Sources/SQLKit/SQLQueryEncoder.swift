public struct SQLQueryEncoder {
    public var prefix: String? = nil
    public var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys

    public init() { }

    public func encode<E>(_ encodable: E) throws -> [(String, SQLExpression)]
        where E: Encodable
    {
        let encoder = _Encoder(options: options)
        try encodable.encode(to: encoder)
        return encoder.row
    }

    public enum KeyEncodingStrategy {
        /// A key encoding strategy that doesn't change key names during encoding.
        case useDefaultKeys
        /// A key encoding strategy that converts camel-case keys to snake-case keys.
        case convertToSnakeCase
        case custom(([CodingKey]) -> CodingKey)
    }

    fileprivate struct _Options {
        let prefix: String?
        let keyEncodingStrategy: KeyEncodingStrategy
    }

    /// The options set on the top-level decoder.
    fileprivate var options: _Options {
        return _Options(prefix: prefix, keyEncodingStrategy: keyEncodingStrategy)
    }
}

private final class _Encoder: Encoder {
    fileprivate let options: SQLQueryEncoder._Options

    var codingPath: [CodingKey] {
        return []
    }

    var userInfo: [CodingUserInfoKey : Any] {
        return [:]
    }

    var row: [(String, SQLExpression)]

    init(options: SQLQueryEncoder._Options) {
        self.row = []
        self.options = options
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(_KeyedEncoder(self))
    }

    struct _KeyedEncoder<Key>: KeyedEncodingContainerProtocol
        where Key: CodingKey
    {
        var codingPath: [CodingKey] {
            return []
        }
        let encoder: _Encoder
        init(_ encoder: _Encoder) {
            self.encoder = encoder
        }

        func column(for key: Key) -> String {
            var encodedKey = key.stringValue
            switch self.encoder.options.keyEncodingStrategy {
            case .useDefaultKeys:
                break
            case .convertToSnakeCase:
                encodedKey = _convertToSnakeCase(encodedKey)
            case .custom(let customKeyEncodingFunc):
                encodedKey = customKeyEncodingFunc([key]).stringValue
            }

            if let prefix = self.encoder.options.prefix {
                return prefix + encodedKey
            } else {
                return encodedKey
            }
        }

        mutating func encodeNil(forKey key: Key) throws {
            self.encoder.row.append((self.column(for: key), SQLLiteral.null))
        }

        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            if let value = value as? SQLExpression {
                self.encoder.row.append((self.column(for: key), value))
            } else {
                self.encoder.row.append((self.column(for: key), SQLBind(value)))
            }
        }

      mutating func _encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        if let value = value {
          try encode(value, forKey: key)
        } else {
          try encodeNil(forKey: key)
        }
      }

      mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable { try _encodeIfPresent(value, forKey: key)}
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

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }

        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            fatalError()
        }

        mutating func superEncoder() -> Encoder {
            return self.encoder
        }

        mutating func superEncoder(forKey key: Key) -> Encoder {
            return self.encoder
        }
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
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

        enum Status {
            case uppercase
            case lowercase
            case number
        }

        var status = Status.lowercase
        var snakeCasedString = ""
        var i = stringKey.startIndex
        while i < stringKey.endIndex {
            let nextIndex = stringKey.index(i, offsetBy: 1)

            if stringKey[i].isUppercase {
                switch status {
                case .uppercase:
                    if nextIndex < stringKey.endIndex {
                        if stringKey[nextIndex].isLowercase {
                            snakeCasedString.append("_")
                        }
                    }
                case .lowercase,
                     .number:
                    if i != stringKey.startIndex {
                        snakeCasedString.append("_")
                    }
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
