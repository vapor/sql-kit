public struct SQLRowDecoder {
    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy: Sendable {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from `snake_case_keys` to `camelCaseKeys` before attempting to match a key with
        /// the one specified by each type.
        ///
        /// Converting from snake case to camel case:
        ///
        /// 1. Capitalizes the word starting after each `_` chartacter.
        /// 2. Removes all `_` characters (except as specified below).
        /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables
        ///    or other metadata).
        /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
        ///
        /// > Note: Using a key decoding strategy has a nominal performance cost, as each string key has
        ///   to be inspected for the `_` character.
        case convertFromSnakeCase

        /// Provide a custom conversion from the key in the encoded row to the keys specified by the
        /// decoded types.
        ///
        /// The full path to the current decoding position is provided for context (in case you need to
        /// locate this key within the payload). The returned key is used in place of the last component
        /// in the coding path before decoding.
        ///
        /// If the result of the conversion is a duplicate key, then only one value will be present in the
        /// container for the type to decode from.
        @preconcurrency
        case custom(@Sendable ([any CodingKey]) -> any CodingKey)
    }

    /// A prefix to be discarded on column names before interpreting them as coding keys.
    @inlinable
    public var prefix: String? {
        get { self.configuration.prefix }
        set { self.configuration.prefix = newValue }
    }
    
    /// The key decoding strategy to use.
    @inlinable
    public var keyDecodingStrategy: KeyDecodingStrategy {
        get { self.configuration.keyDecodingStrategy }
        set { self.configuration.keyDecodingStrategy = newValue }
    }
    
    /// User info to provide to the underlying `Decoder`.
    @inlinable
    public var userInfo: [CodingUserInfoKey: Any] {
        get { self.configuration.userInfo }
        set { self.configuration.userInfo = newValue }
    }

    /// Create an ``SQLRowDecoder``.
    public init(
        prefix: String? = nil,
        keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.configuration = .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo)
    }

    /// Decode a value of type `T` from the given ``SQLRow``.
    func decode<T: Decodable>(_: T.Type, from row: some SQLRow) throws -> T {
        try T.init(from: SQLRowDecoderImpl(
            row: row,
            configuration: self.configuration
        ))
    }

    /// Encapsulates the configuration of an ``SQLRowDecoder``.
    @usableFromInline
    struct Configuration {
        @usableFromInline var prefix: String? = nil
        @usableFromInline var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
        @usableFromInline var userInfo: [CodingUserInfoKey: Any] = [:]
        @inlinable init() {}
        @inlinable init(
            prefix: String?,
            keyDecodingStrategy: KeyDecodingStrategy,
            userInfo: [CodingUserInfoKey : Any]
        ) {
            self.prefix = prefix
            self.keyDecodingStrategy = keyDecodingStrategy
            self.userInfo = userInfo
        }
    }
    
    @usableFromInline
    internal var configuration: Configuration = .init()

    /// Underlying implementation.
    fileprivate final class SQLRowDecoderImpl<Row: SQLRow>: Decoder {
        let configuration: Configuration
        let row: Row
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] { self.configuration.userInfo }

        init(
            row: Row,
            codingPath: [any CodingKey] = [],
            configuration: Configuration
        ) {
            self.row = row
            self.codingPath = codingPath
            self.configuration = configuration
        }

        func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> { .init(KeyedContainer(self)) }
        
        func unkeyedContainer() throws -> any UnkeyedDecodingContainer { throw .invalid(in: self) }
        
        func singleValueContainer() throws -> any SingleValueDecodingContainer { throw .invalid(in: self) }

        private struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
            var codingPath: [any CodingKey] { self.decoder.codingPath }
            let decoder: SQLRowDecoderImpl
            let codingKeyToColumnNameMap: [String: String]

            init(_ decoder: SQLRowDecoderImpl) {
                self.decoder = decoder
                self.codingKeyToColumnNameMap = .init(uniqueKeysWithValues: decoder.row
                    .allColumns
                    .map {
                        ($0, String($0.drop(prefix: decoder.configuration.prefix)))
                    }.map {
                        switch decoder.configuration.keyDecodingStrategy {
                        case .useDefaultKeys:       return ($1, $0)
                        case .convertFromSnakeCase: return ($1.convertedFromSnakeCase, $0)
                        case .custom(let custom):   return (custom(decoder.codingPath + [$1.codingKeyValue]).stringValue, $0)
                        }
                    }
                )
            }

            private func withColumn<R>(for key: Key, _ closure: (String) throws -> R) throws -> R {
                guard let name = self.codingKeyToColumnNameMap[key.stringValue] else {
                    throw DecodingError.keyNotFound(key, .init(
                        codingPath: self.codingPath,
                        debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."
                    ))
                }
                
                self.decoder.codingPath.append(key)
                defer { self.decoder.codingPath.removeLast() }
                
                do { return try closure(name) }
                catch DecodingError.valueNotFound(let type, let context) { throw DecodingError.valueNotFound(type, context.with(prefix: self.codingPath)) }
                catch DecodingError.dataCorrupted(let context)           { throw DecodingError.dataCorrupted(context.with(prefix: self.codingPath)) }
                catch DecodingError.typeMismatch(let type, let context)  { throw DecodingError.typeMismatch(type, context.with(prefix: self.codingPath)) }
                catch DecodingError.keyNotFound(let ekey, let context)   { throw DecodingError.keyNotFound(ekey, context.with(prefix: self.codingPath)) }
            }

            var allKeys: [Key] {
                self.codingKeyToColumnNameMap.keys.compactMap(Key.init(stringValue:))
            }
            
            func contains(_ key: Key) -> Bool {
                self.codingKeyToColumnNameMap[key.stringValue].map { self.decoder.row.contains(column: $0) } ?? false
            }
            
            func decodeNil(forKey key: Key) throws -> Bool                { try self.withColumn(for: key) { try self.decoder.row.decodeNil(column: $0) } }
            func decode(_: Bool.Type,   forKey key: Key) throws -> Bool   { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: String.Type, forKey key: Key) throws -> String { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Double.Type, forKey key: Key) throws -> Double { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Float.Type,  forKey key: Key) throws -> Float  { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Int.Type,    forKey key: Key) throws -> Int    { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Int8.Type,   forKey key: Key) throws -> Int8   { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Int16.Type,  forKey key: Key) throws -> Int16  { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Int32.Type,  forKey key: Key) throws -> Int32  { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: Int64.Type,  forKey key: Key) throws -> Int64  { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: UInt.Type,   forKey key: Key) throws -> UInt   { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: UInt8.Type,  forKey key: Key) throws -> UInt8  { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: UInt16.Type, forKey key: Key) throws -> UInt16 { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: UInt32.Type, forKey key: Key) throws -> UInt32 { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode(_: UInt64.Type, forKey key: Key) throws -> UInt64 { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0)    } }
            func decode<T: Decodable>(_: T.Type, forKey key: Key) throws -> T { try self.withColumn(for: key) { try self.decoder.row.decode(column: $0) } }

            func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey key: Key) throws -> KeyedDecodingContainer<N> {
                throw .invalid(in: self, key: key)
            }
            func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
                throw .invalid(in: self, key: key)
            }
            func superDecoder() throws -> any Decoder {
                throw .invalid(in: self.decoder)
            }
            func superDecoder(forKey key: Key) throws -> any Decoder {
                throw .invalid(in: self, key: key)
            }
        }
    }
}
