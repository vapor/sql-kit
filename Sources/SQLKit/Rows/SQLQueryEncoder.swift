public struct SQLQueryEncoder {
    /// The strategy to use for handling `nil` input values.
    public enum NilEncodingStrategy {
        /// Encode nothing at all for columns with `nil` values.
        case `default`

        /// Encode an explicit `NULL` value for columns with `nil` values.
        ///
        /// Intended for use with ``SQLInsertBuilder/model(_:prefix:keyEncodingStrategy:nilEncodingStrategy:)``
        /// and ``SQLInsertBuilder/models(_:prefix:keyEncodingStrategy:nilEncodingStrategy:)``.
        case asNil
    }

    /// The strategy to use for automatically changing the value of keys before encoding.
    public enum KeyEncodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from `camelCaseKeys` to `snake_case_keys` before writing a key to a row.
        ///
        /// Capital characters are determined by testing `Character.isUppercase`.
        ///
        /// Converting from camel case to snake case:
        ///
        /// 1. Splits words at the boundary of lower-case to upper-case.
        /// 2. Inserts `_` between words.
        /// 3. Lowercases the entire string.
        /// 4. Preserves starting and ending `_`.
        ///
        /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
        ///
        /// > Note: Using a key encoding strategy has a nominal performance cost, as each string key has
        ///   to be converted.
        case convertToSnakeCase

        /// Provide a custom conversion to the key in the encoded row from the keys specified by the
        /// encoded types.

        /// The full path to the current encoding position is provided for context (in case you need to
        /// locate this key within the payload). The returned key is used in place of the last component
        /// in the coding path before encoding.
        ///
        /// If the result of the conversion is a duplicate key, then only one value will be present in
        /// the result.
        @preconcurrency case custom(@Sendable (_ codingPath: [any CodingKey]) -> any CodingKey)
    }
    
    /// A prefix to be added to keys when encoding column names.
    @inlinable
    public var prefix: String? {
        get { self.configuration.prefix }
        set { self.configuration.prefix = newValue }
    }
    
    /// The key encoding strategy to use.
    @inlinable
    public var keyEncodingStrategy: KeyEncodingStrategy {
        get { self.configuration.keyEncodingStrategy }
        set { self.configuration.keyEncodingStrategy = newValue }
    }
    
    /// The `nil` value encoding strategy to use.
    @inlinable
    public var nilEncodingStrategy: NilEncodingStrategy {
        get { self.configuration.nilEncodingStrategy }
        set { self.configuration.nilEncodingStrategy = newValue }
    }
    
    /// User info to provide to the underlying `Encoder`.
    @inlinable
    public var userInfo: [CodingUserInfoKey: Any] {
        get { self.configuration.userInfo }
        set { self.configuration.userInfo = newValue }
    }

    /// Create an `SQLQueryEncoder` with default settings.
    @inlinable
    public init() {}
    
    /// Create an `SQLQueryEncoder`, specifying some or all settings.
    @inlinable
    public init(
        prefix: String? = nil,
        keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: NilEncodingStrategy = .default,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.configuration = .init(
            prefix: prefix,
            keyEncodingStrategy: keyEncodingStrategy,
            nilEncodingStrategy: nilEncodingStrategy,
            userInfo: userInfo
        )
    }

    /// Encode an `Encodable` value to an array of key/expression pairs suitable for
    /// providing to an ``SQLInsertBuilder``.
    public func encode(_ encodable: some Encodable) throws -> [(String, any SQLExpression)] {
        let encoder = SQLQueryEncoderImpl(configuration: self.configuration)
        try encodable.encode(to: encoder)
        return encoder.row
    }

    /// Encapsulates the configuration of an ``SQLQueryEncoder``.
    @usableFromInline
    struct Configuration {
        @usableFromInline var prefix: String? = nil
        @usableFromInline var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
        @usableFromInline var nilEncodingStrategy: NilEncodingStrategy = .default
        @usableFromInline var userInfo: [CodingUserInfoKey: Any] = [:]
        @inlinable init() {}
        @inlinable init(
            prefix: String?,
            keyEncodingStrategy: KeyEncodingStrategy,
            nilEncodingStrategy: NilEncodingStrategy,
            userInfo: [CodingUserInfoKey : Any]
        ) {
            self.prefix = prefix
            self.keyEncodingStrategy = keyEncodingStrategy
            self.nilEncodingStrategy = nilEncodingStrategy
            self.userInfo = userInfo
        }
    }
    
    @usableFromInline
    internal var configuration: Configuration = .init()
    
    /// Underlying implementation.
    fileprivate final class SQLQueryEncoderImpl: Encoder {
        let configuration: Configuration
        var row: [(String, any SQLExpression)] = []
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] { self.configuration.userInfo }

        init(configuration: Configuration) {
            self.configuration = configuration
        }

        func container<Key: CodingKey>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
            .init(KeyedContainer(encoder: self, nils: self.configuration.nilEncodingStrategy == .asNil))
        }
        
        func unkeyedContainer() -> any UnkeyedEncodingContainer {
             FailureEncoder(.invalid(in: self))
        }
        
        func singleValueContainer() -> any SingleValueEncodingContainer {
            FailureEncoder(.invalid(in: self))
        }

        @inlinable
        func withColumnName(for key: some CodingKey, _ closure: (String, inout [(String, any SQLExpression)]) -> Void) {
            let encodedKey: String

            switch self.configuration.keyEncodingStrategy {
            case .useDefaultKeys:       encodedKey = key.stringValue
            case .convertToSnakeCase:   encodedKey = key.stringValue.convertedToSnakeCase
            case .custom(let closure):  encodedKey = closure(self.codingPath + [key]).stringValue
            }

            self.codingPath.append(key)
            defer { self.codingPath.removeLast() }

            closure("\(self.configuration.prefix ?? "")\(encodedKey)", &self.row)
        }
        
        private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
            var codingPath: [any CodingKey] { self.encoder.codingPath }
            let encoder: SQLQueryEncoderImpl
            let nils: Bool

            mutating func encodeNil(forKey key: Key)               throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLLiteral.null)) } }
            mutating func encode(_ value: Bool,   forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLLiteral.boolean(value))) } }
            mutating func encode(_ value: String, forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Double, forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Float,  forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Int,    forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Int8,   forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Int16,  forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Int32,  forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: Int64,  forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: UInt,   forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: UInt16, forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: UInt32, forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: UInt64, forKey key: Key) throws { self.encoder.withColumnName(for: key) { $1.append(($0, SQLBind(value))) } }
            mutating func encode(_ value: some Encodable, forKey key: Key) throws {
                self.encoder.withColumnName(for: key) {
                    $1.append(($0, (value as? any SQLExpression) ?? SQLBind(value)))
                }
            }
            mutating func encodeIfPresent(_ v: Bool?,   forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: String?, forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Double?, forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Float?,  forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Int?,    forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Int8?,   forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Int16?,  forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Int32?,  forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: Int64?,  forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: UInt?,   forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: UInt16?, forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: UInt32?, forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: UInt64?, forKey k: Key) throws { if let v { try self.encode(v, forKey: k) } else if self.nils { try self.encodeNil(forKey: k) } }
            mutating func encodeIfPresent(_ v: (some Encodable)?, forKey k: Key) throws {
                if let v {
                    try self.encode(v, forKey: k)
                } else if self.nils {
                    try self.encodeNil(forKey: k)
                }
            }

            mutating func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey key: Key) -> KeyedEncodingContainer<N> {
                .init(FailureEncoder(.invalid(in: self, key: key)))
            }
            mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
                FailureEncoder(.invalid(in: self, key: key))
            }
            mutating func superEncoder() -> any Encoder {
                FailureEncoder(.invalid(in: self.encoder))
            }
            mutating func superEncoder(forKey key: Key) -> any Encoder {
                FailureEncoder(.invalid(in: self, key: key))
            }
        }
    }
}

