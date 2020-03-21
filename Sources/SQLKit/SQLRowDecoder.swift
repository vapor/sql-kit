import Foundation

public struct SQLRowDecoder {
    public var prefix: String?
    public var keyDecodingStrategy: KeyDecodingStrategy

    public init(prefix: String? = nil, keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys) {
        self.prefix = prefix
        self.keyDecodingStrategy = keyDecodingStrategy
    }

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
                decodedKey = _convertFromSnakeCase(decodedKey)
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
    /// This is an implementation is taken from from Swift's JSON KeyDecodingStrategy
    /// https://github.com/apple/swift/blob/master/stdlib/public/Darwin/Foundation/JSONEncoder.swift

    // Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
    ///
    /// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
    ///
    /// Converting from snake case to camel case:
    /// 1. Capitalizes the word starting after each `_`
    /// 2. Removes all `_`
    /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
    /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
    ///
    /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
    static func _convertFromSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }

        var words : [Range<String.Index>] = []
        // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
        //
        // myProperty -> my_property
        // myURLProperty -> my_url_property
        //
        // We assume, per Swift naming conventions, that the first character of the key is lowercase.
        var wordStart = stringKey.startIndex
        var searchRange = stringKey.index(after: wordStart)..<stringKey.endIndex

        // Find next uppercase character
        while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
            let untilUpperCase = wordStart..<upperCaseRange.lowerBound
            words.append(untilUpperCase)

            // Find next lowercase character
            searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
            guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                // There are no more lower case letters. Just end here.
                wordStart = searchRange.lowerBound
                break
            }

            // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
            let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                // The next character after capital is a lower case character and therefore not a word boundary.
                // Continue searching for the next upper case for the boundary.
                wordStart = upperCaseRange.lowerBound
            } else {
                // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                // Next word starts at the capital before the lowercase we just found
                wordStart = beforeLowerIndex
            }
            searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
        }
        words.append(wordStart..<searchRange.upperBound)
        let result = words.map({ (range) in
            return stringKey[range].lowercased()
        }).joined(separator: "_")
        return result
    }
}
