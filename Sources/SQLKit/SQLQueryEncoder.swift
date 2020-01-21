public struct SQLQueryEncoder {
    public init() { }

    public func encode<E>(_ encodable: E) throws -> [(String, SQLExpression)]
        where E: Encodable
    {
        let encoder = _Encoder()
        try encodable.encode(to: encoder)
        return encoder.row
    }
}

private final class _Encoder: Encoder {
    var codingPath: [CodingKey] {
        return []
    }

    var userInfo: [CodingUserInfoKey : Any] {
        return [:]
    }

    var row: [(String, SQLExpression)]

    init() {
        self.row = []
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

        mutating func encodeNil(forKey key: Key) throws {
            self.encoder.row.append((key.stringValue, SQLLiteral.null))
        }

        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            if let value = value as? SQLExpression {
                self.encoder.row.append((key.stringValue, value))
            } else {
                self.encoder.row.append((key.stringValue, SQLBind(value)))
            }
        }

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
