public struct SQLRowDecoder {
    public var prefix: String? = nil
    public var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    func decode<T>(_ type: T.Type, from row: SQLRow) throws -> T
        where T: Decodable
    {
        return try T.init(from: _Decoder(row: row, options: options))
    }

    public enum KeyDecodingStrategy {
        case useDefaultKeys
        // converts rows in snake_case to from coding keys in camelCase to 
        case convertFromSnakeCase
        case custom(([CodingKey]) -> CodingKey)
    }

    fileprivate struct _Options {
        let prefix: String?
        let keyDecodingStrategy: KeyDecodingStrategy
    }

    /// The options set on the top-level decoder.
    fileprivate var options: _Options {
        return _Options(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy)
    }

    enum _Error: Error {
        case nesting
        case unkeyedContainer
        case singleValueContainer
    }

    struct _Decoder: Decoder {
        fileprivate let options: SQLRowDecoder._Options
        let row: SQLRow
        var codingPath: [CodingKey] = []
        var userInfo: [CodingUserInfoKey : Any] {
            [:]
        }

        fileprivate init(row: SQLRow, codingPath: [CodingKey] = [], options: _Options) {
            self.options = options
            self.row = row
            self.codingPath = codingPath
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
            where Key: CodingKey
        {
            .init(_KeyedDecoder(referencing: self, row: self.row, codingPath: self.codingPath))
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
        /// A reference to the decoder we're reading from.
        private let decoder: _Decoder
        let row: SQLRow
        var codingPath: [CodingKey] = []
        var allKeys: [Key] {
            self.row.allColumns.compactMap {
                Key.init(stringValue: $0)
            }
        }

        fileprivate init(referencing decoder: _Decoder, row: SQLRow, codingPath: [CodingKey] = []) {
            self.decoder = decoder
            self.row = row
        }

        func column(for key: Key) -> String {
            var decodedKey = key.stringValue
            switch self.decoder.options.keyDecodingStrategy {
            case .useDefaultKeys:
                break
            case .convertFromSnakeCase:
                decodedKey = _convertToSnakeCase(decodedKey)
            case .custom(let customKeyDecodingFunc):
                decodedKey = customKeyDecodingFunc([key]).stringValue
            }

            if let prefix = self.decoder.options.prefix {
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
            _Decoder(row: self.row, codingPath: self.codingPath, options: self.decoder.options)
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            throw _Error.nesting
        }
    }
}

fileprivate extension SQLRowDecoder {
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
