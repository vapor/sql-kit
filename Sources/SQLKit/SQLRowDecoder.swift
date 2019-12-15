struct SQLRowDecoder {
    func decode<T>(_ type: T.Type, from row: SQLRow, prefix: String? = nil, keyDecodingStrategy: SQlRowKeyDecodingStrategy = .useDefaultKeys) throws -> T
        where T: Decodable
    {
        return try T.init(from: _Decoder(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, row: row))
    }

    enum _Error: Error {
        case nesting
        case unkeyedContainer
        case singleValueContainer
    }

    struct _Decoder: Decoder {
        let prefix: String?
        let keyDecodingStrategy: SQlRowKeyDecodingStrategy
        let row: SQLRow
        var codingPath: [CodingKey] = []
        var userInfo: [CodingUserInfoKey : Any] {
            [:]
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
            where Key: CodingKey
        {
            .init(_KeyedDecoder(prefix: self.prefix, keyDecodingStrategy: self.keyDecodingStrategy, row: self.row, codingPath: self.codingPath))
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            throw _Error.unkeyedContainer
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            throw _Error.singleValueContainer
        }
    }

    struct _KeyedDecoder<Key>: KeyedDecodingContainerProtocol
        where Key: CodingKey
    {
        let prefix: String?
        let keyDecodingStrategy: SQlRowKeyDecodingStrategy
        let row: SQLRow
        var codingPath: [CodingKey] = []
        var allKeys: [Key] {
            self.row.allColumns.compactMap {
                Key.init(stringValue: $0)
            }
        }

        func column(for key: Key) -> String {
            var decodedKey = key.stringValue
            switch self.keyDecodingStrategy {
            case .useDefaultKeys:
                break
            case .convertFromSnakeCase:
                decodedKey = decodedKey.snakeCased()
            case .custom(let customKeyDecodingFunc):
                decodedKey = customKeyDecodingFunc([key]).stringValue
            }

            if let prefix = self.prefix {
                return prefix + decodedKey
            } else {
                return decodedKey
            }
        }

        func contains(_ key: Key) -> Bool {
            self.row.contains(column: self.column(for: key))
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            try self.row.decodeNil(column: self.column(for: key))
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T
            where T : Decodable
        {
            try self.row.decode(column: self.column(for: key), as: T.self)
        }

        func nestedContainer<NestedKey>(
            keyedBy type: NestedKey.Type,
            forKey key: Key
        ) throws -> KeyedDecodingContainer<NestedKey>
            where NestedKey : CodingKey
        {
            throw _Error.nesting
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            throw _Error.nesting
        }

        func superDecoder() throws -> Decoder {
            _Decoder(prefix: self.prefix, keyDecodingStrategy: self.keyDecodingStrategy, row: self.row, codingPath: self.codingPath)
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            throw _Error.nesting
        }
    }
}

fileprivate extension String {
    /// Returns a new string in snake cased format
    ///
    ///     "ThisIsATest".snakeCased() //returns this_is_a_test
    ///     "JSON123Test".snakeCased() //returns json_123_test
    func snakeCased() -> String {
        enum Status {
            case uppercase
            case number
            case lowercase
        }

        var status = Status.lowercase
        var snakeCasedString = ""
        var i = self.startIndex
        while i < self.endIndex {
            let nextIndex = self.index(i, offsetBy: 1)

            if self[i].isUppercase {
                switch status {
                case .uppercase:
                    if nextIndex < self.endIndex {
                        if self[nextIndex].isLowercase {
                            snakeCasedString.append("_")
                        }
                    }
                case .number:
                    if i != self.startIndex {
                        snakeCasedString.append("_")
                    }
                case .lowercase:
                    if i != self.startIndex {
                        snakeCasedString.append("_")
                    }
                }
                status = .uppercase
                snakeCasedString.append(self[i].lowercased())
            } else if self[i].isNumber {
                switch status {
                case .number:
                    break
                case .uppercase:
                    if i != self.startIndex {
                        snakeCasedString.append("_")
                    }
                case .lowercase:
                    if i != self.startIndex {
                        snakeCasedString.append("_")
                    }
                }
                status = .number
                snakeCasedString.append(self[i])
            } else {
                status = .lowercase
                snakeCasedString.append(self[i])
            }

            i = nextIndex
        }

        return snakeCasedString
    }
}
