import struct OrderedCollections.OrderedDictionary

/// An implementation of `Encoder` designed to encode "models" (or, in general, aggregate `Encodable` types) into a
/// form which can be used as input to a database query.
///
/// At present, there is no "input"-capable equivalent of an ``SQLRow``, so this encoder returns a somewhat awkward
/// array of "column name"/"value expression" pairs.
///
/// This type is, somewhat confusingly, designed primarily for use with methods such as
/// 
/// - ``SQLInsertBuilder``:
///   - ``SQLInsertBuilder/model(_:prefix:keyEncodingStrategy:nilEncodingStrategy:userInfo:)``
///   - ``SQLInsertBuilder/model(_:with:)``
///   - ``SQLInsertBuilder/models(_:prefix:keyEncodingStrategy:nilEncodingStrategy:userInfo:)``
///   - ``SQLInsertBuilder/models(_:with:)``
/// - ``SQLColumnUpdateBuilder``:
///   - ``SQLColumnUpdateBuilder/set(model:prefix:keyEncodingStrategy:nilEncodingStrategy:userInfo:)``
///   - ``SQLColumnUpdateBuilder/set(model:with:)``
/// - ``SQLConflictUpdateBuilder``:
///   - ``SQLConflictUpdateBuilder/set(excludedContentOf:prefix:keyEncodingStrategy:nilEncodingStrategy:userInfo:)``
///   - ``SQLConflictUpdateBuilder/set(excludedContentOf:with:)``
///
/// It can also be manually invoked. For example:
///
/// ```swift
/// struct MySimpleUserModel: Codable {
///     var id: Int? = nil
///     var username: String
///     var passwordHash: [UInt8]
///     var email: String?
///     var createdAt: Date
/// }
///
/// let users: [MySimpleUserModel] = [
///     .init(username: "johndoe", passwordHash: (0..<32).random(in: .min ... .max), email: "foo@bar.com", createdAt: .init()),
///     .init(username: "janedoe", passwordHash: (0..<32).random(in: .min ... .max), email: nil, createdAt: .init()),
/// ]
///
/// // Direct usage (not recommended):
/// let encoder = SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil)
/// let rows = try users.map { user in try encoder.encode(user) }
/// let query = sqlDatabase
///     .insert(into: "my_simple_users")
///     .columns(rows[0].map(\.0))
/// for row in rows {
///     query.values(row.map(\.1))
/// }
/// try await query.run()
///
/// // Invoked via SQLInsertBuilder and SQLConflictUpdateBuilder:
/// let encoder = SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil)
/// try await sqlDatabase.insert(into: "my_simple_users")
///     .models(users, with: encoder)
///     .onConflict { $0.set(excludedContentOf: users[0], with: encoder) }
///     .run()
///
/// // Invoked via SQLUpdateBuilder:
/// try await sqlDatabase.update("my_simple_users")
///     .set(model: users[0], keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil)
///     .where("id", .equal, SQLBind(1))
///     .run()
/// ```
public struct SQLQueryEncoder: Sendable {
    /// A strategy describing the desired encoding of `nil` input values.
    public enum NilEncodingStrategy: Sendable {
        /// Encode nothing at all for columns with `nil` values.
        case `default`

        /// Encode an explicit `NULL` value for columns with `nil` values.
        ///
        /// Intended for use with ``SQLInsertBuilder/model(_:prefix:keyEncodingStrategy:nilEncodingStrategy:userInfo:)``
        /// and ``SQLInsertBuilder/models(_:prefix:keyEncodingStrategy:nilEncodingStrategy:userInfo:)``.
        case asNil
    }

    /// A strategy describing how to transform individual keys into encoded column names.
    public enum KeyEncodingStrategy: Sendable {
        /// Use input keys unmodified. This is the default strategy.
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
        /// > to be converted.
        case convertToSnakeCase

        /// Provide a custom conversion to the key in the encoded row from the keys specified by the
        /// encoded types.
        ///
        /// The full path to the current encoding position is provided for context (in case you need to
        /// locate this key within the payload). The returned key is used in place of the last component
        /// in the coding path before encoding.
        ///
        /// If the result of the conversion is a duplicate key, then only one value will be present in
        /// the result.
        @preconcurrency
        case custom(@Sendable (_ codingPath: [any CodingKey]) -> any CodingKey)
        
        /// Apply the strategy to the given coding key, returning the transformed result.
        ///
        /// This is a _forward_ transformation, converting a coding key from the provided model type to a column
        /// name which will be stored in the database.
        fileprivate func apply(to name: any CodingKey) -> String {
            switch self {
            case .useDefaultKeys:
                return name.stringValue
            case .convertToSnakeCase:
                return name.stringValue.convertedToSnakeCase
            case .custom(let closure):
                return closure([name]).stringValue
            }
        }
    }
    
    /// A prefix to be added to keys when encoding column names.
    ///
    /// The ``prefix``, if set, is applied _after_ the ``keyEncodingStrategy-swift.property``.
    ///
    /// Example:
    ///
    /// Prefix|Strategy|Coding key|Column name
    /// -|-|-|-
    /// _nil_|``KeyEncodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`FooBar`
    /// `p`|``KeyEncodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`pFooBar`
    /// _nil_|``KeyEncodingStrategy-swift.enum/convertToSnakeCase``|`FooBar`|`foo_bar`
    /// `p`|``KeyEncodingStrategy-swift.enum/convertToSnakeCase``|`FooBar`|`pfoo_bar`
    public var prefix: String?
    
    /// The key encoding strategy to use.
    ///
    /// The ``prefix``, if set, is applied _after_ the ``keyEncodingStrategy-swift.property``.
    ///
    /// Example:
    ///
    /// Prefix|Strategy|Coding key|Column name
    /// -|-|-|-
    /// _nil_|``KeyEncodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`FooBar`
    /// `p`|``KeyEncodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`pFooBar`
    /// _nil_|``KeyEncodingStrategy-swift.enum/convertToSnakeCase``|`FooBar`|`foo_bar`
    /// `p`|``KeyEncodingStrategy-swift.enum/convertToSnakeCase``|`FooBar`|`pfoo_bar`
    public var keyEncodingStrategy: KeyEncodingStrategy
    
    /// The `nil` value encoding strategy to use.
    public var nilEncodingStrategy: NilEncodingStrategy
    
    /// User info to provide to the underlying `Encoder`.
    public var userInfo: [CodingUserInfoKey: any Sendable]

    /// Create a configured ``SQLQueryEncoder``.
    ///
    /// - Parameters:
    ///   - prefix: The key prefix to use for column names. Defaults to none. See ``prefix`` for details.
    ///   - keyEncodingStrategy: The key encoding strategy used for translating coding keys to column names. Defaults
    ///     to ``KeyEncodingStrategy-swift.enum/useDefaultKeys``. See ``keyEncodingStrategy-swift.property`` for
    ///     details.
    ///   - nilEncodingStrategy: The strategy used for encoding `nil` values. Defaults to
    ///     ``NilEncodingStrategy-swift.enum/default``. See ``nilEncodingStrategy-swift.property`` for details.
    ///   - userInfo: Key-value pairs to provide as user info to the underlying encoder. Defaults to none.
    public init(
        prefix: String? = nil,
        keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: NilEncodingStrategy = .default,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) {
        self.prefix = prefix
        self.keyEncodingStrategy = keyEncodingStrategy
        self.nilEncodingStrategy = nilEncodingStrategy
        self.userInfo = userInfo
    }

    /// Encode an `Encodable` value to an array of key/expression pairs suitable for use as input to
    /// ``SQLInsertBuilder/values(_:)-1pro8``, ``SQLColumnUpdateBuilder/set(_:to:)-dnbq``, and other related APIs.
    ///
    /// - Parameter encodable: The value to encode.
    /// - Returns: A sequence of (column name, value expression) pairs representing an output row. The order of the
    ///   results is considered significant, although it will rarely be meaningful in practice.
    public func encode(_ encodable: some Encodable) throws -> [(String, any SQLExpression)] {
        let encoder = SQLQueryEncoderImpl(configuration: self, output: .init())
        
        try encodable.encode(to: encoder)
        return encoder.output.row.map { $0 }
    }

    /// Underlying implementation.
    private struct SQLQueryEncoderImpl: Encoder {
        /// A trivial reference-type wrapper around `OrderedDictionary`.
        final class Output {
            var row: OrderedDictionary<String, any SQLExpression> = [:]
        }
        
        /// Holds configuration information for the encoding process.
        let configuration: SQLQueryEncoder
        
        /// Holds a reference, shared with any subencoders, to the final encoded output.
        var output: Output
        
        // See `Encoder.codingPath`.
        var codingPath: [any CodingKey] = []
        
        // See `Encoder.userInfo`.
        var userInfo: [CodingUserInfoKey: Any] {
            self.configuration.userInfo
        }

        // See `Encoder.container(keyedBy:)`.
        func container<Key: CodingKey>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
            /// If the coding path is not empty, we have reached this point via `superEncoder(forKey:)`, from which
            /// the only valid request is for a single-value container. Since this method cannot throw directly,
            /// return a ``FailureEncoder`` which will throw the error at the earliest possible opportunity.
            guard self.codingPath.isEmpty else {
                return .invalid(at: self.codingPath)
            }
            
            /// Otherwise, a keyed container request is valid.
            return .init(KeyedContainer(encoder: self))
        }

        // See `Encoder.unkeyedContainer()`.
        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            /// It is never valid to request an unkeyed container in the current implementation. In a design having
            /// differing public API, a row could be conceivably treated as an unkeyed container if written in terms
            /// of column indexes rather than column names. Since this method cannot throw directly, return a
            /// ``FailureEncoder`` which will throw the error at the earliest possible opportunity.
            .invalid(at: self.codingPath)
        }

        // See `Encoder.singleValueContainer()`.
        func singleValueContainer() -> any SingleValueEncodingContainer {
            SingleValueContainer(encoder: self)
        }

        /// Store a given expression in the output using the transformed column name for a given key.
        ///
        /// Setting the same input key (and thus output column name) more than once overwrites previous values.
        private func set(_ expr: any SQLExpression, forKey key: some CodingKey) {
            self.output.row["\(self.configuration.prefix ?? "")\(self.configuration.keyEncodingStrategy.apply(to: key))"] = expr
        }
        
        /// An implementation of `KeyedEncodingContainerProtocol` for ``SQLQueryEncoderImpl``.
        private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
            // See `KeyedEncodingContainerProtocol.codingPath`.
            var codingPath: [any CodingKey] {
                self.encoder.codingPath
            }
            
            /// Trivial helper to shorten the expression which checks the nil encoding strategy.
            var nils: Bool {
                self.encoder.configuration.nilEncodingStrategy == .asNil
            }
            
            /// The encoder which created this container.
            let encoder: SQLQueryEncoderImpl
            
            // See `KeyedEncodingContainerProtocol.encodeNil(forKey:)`.
            mutating func encodeNil(forKey key: Key) throws {
                /// Deliberately do _not_ check the ``SQLQueryEncoder/nilEncodingStrategy-swift.property`` here,
                /// so that `encodeNil(forKey:)` may be used to encode explicit `NULL` values even when the strategy
                /// in use requires skipping `nil` values. (This method is also invoked when the strategy calls for
                /// explicitly encoding such values, making such a check redundant as well.) The strategy _is_
                /// respected by the `encodeIfPresent(_:forKey:)` methods.
                self.encoder.set(SQLLiteral.null, forKey: key)
            }
            
            /// We must provide the fourteen fundamental type overloads in order to elide the need for the
            /// `FakeSendable` wrapper for those values, which saves a significant amount of unnecessary overhead.
            
            // See `KeyedEncodingContainerProtocol.encode(_:forKey:)`.
            mutating func encode(_ value: Bool,   forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: String, forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Double, forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Float,  forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Int,    forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Int8,   forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Int16,  forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Int32,  forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: Int64,  forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: UInt,   forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: UInt8,  forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: UInt16, forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: UInt32, forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }
            mutating func encode(_ value: UInt64, forKey key: Key) throws { self.encoder.set(SQLBind(value), forKey: key) }

            // See `KeyedEncodingContainerProtocol.encode(_:forKey:)`.
            mutating func encode(_ value: some Encodable, forKey key: Key) throws {
                /// For generic `Encodable` values, we must forcibly silence the `Sendable` warning from ``SQLBind``.
                self.encoder.set((value as? any SQLExpression) ?? SQLBind(FakeSendableCodable(value)), forKey: key)
            }
            
            /// Because each `encodeIfPresent(_:forKey:)` method is given a default implementation by the
            /// `KeyedEncodingContainerProtocol` protocol, all fourteen overloads must be overridden in order to
            /// provide the desired semantics. The content of each overload also cannot be generalized in a generic
            /// method because we need concrete dispatch for the fundamental types in order to avoid excess usage
            /// of the `FakeSendable` wrapper.
            
            // See `KeyedEncodingContainerProtocol.encodeIfPresent(_:forKey:)`.
            mutating func encodeIfPresent(_ val: Bool?,   forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: String?, forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Double?, forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Float?,  forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Int?,    forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Int8?,   forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Int16?,  forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Int32?,  forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: Int64?,  forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: UInt?,   forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: UInt8?,  forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: UInt16?, forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: UInt32?, forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: UInt64?, forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }
            mutating func encodeIfPresent(_ val: (some Encodable)?, forKey key: Key) throws { if let val { try self.encode(val, forKey: key) } else if self.nils { try self.encodeNil(forKey: key) } }

            // See `KeyedEncodingContainerProtocol.superEncoder(forKey:)`.
            mutating func superEncoder(forKey key: Key) -> any Encoder {
                /// Return a valid encoder so that implementations which then encode scalar values into a
                /// single-value container may operate properly. Recursion back into the keyed container path is
                /// prevented by the check for an empty coding path in `container(keyedBy:)`.
                SQLQueryEncoderImpl(
                    configuration: self.encoder.configuration,
                    output: self.encoder.output,
                    codingPath: self.codingPath + [key]
                )
            }

            // See `KeyedEncodingContainerProtocol.nestedContainer(keyedBy:forKey:)`.
            mutating func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey key: Key) -> KeyedEncodingContainer<N> {
                /// Nested containers are never supported. Since this method cannot throw directly, return a
                /// ``FailureEncoder`` which will throw the error at the earliest possible opportunity.
                .invalid(at: self.codingPath + [key])
            }

            // See `KeyedEncodingContainerProtocol.nestedUnkeyedContainer(forKey:)`.
            mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
                /// Neither nested nor unkeyed containers are supported. Since this method cannot throw directly,
                /// return a ``FailureEncoder`` which will throw the error at the earliest possible opportunity.
                .invalid(at: self.codingPath + [key])
            }

            // See `KeyedEncodingContainerProtocol.superEncoder()`.
            mutating func superEncoder() -> any Encoder {
                /// This method is ostensibly equivalent to `superEncoder(forKey: "super")`, but conceptually does not
                /// have the same meaning; its actual intent is not supported. Since this method cannot throw directly,
                /// return a ``FailureEncoder`` which will throw the error at the earliest possible opportunity.
                .invalid(at: self.codingPath)
            }
        }
        
        /// An implementation of `SingleValueEncodingContainer` for ``SQLQueryEncoderImpl``.
        private struct SingleValueContainer: SingleValueEncodingContainer {
            // See `SingleValueEncodingContainer.codingPath`.
            var codingPath: [any CodingKey] {
                self.encoder.codingPath
            }
            
            /// The encoder which created this container.
            let encoder: SQLQueryEncoderImpl
            
            // See `SingleValueEncodingContainer.encodeNil()`.
            mutating func encodeNil() throws {
                /// If the coding path is empty, the attempt to encode a scalar value is taking place on the
                /// top-level encoder, which is invalid.
                guard let key = self.codingPath.last else {
                    throw .invalid(at: self.codingPath)
                }
                
                /// Account for the configured ``SQLQueryEncoder/nilEncodingStrategy-swift.property``.
                guard self.encoder.configuration.nilEncodingStrategy == .asNil else {
                    return
                }
                
                self.encoder.set(SQLLiteral.null, forKey: key)
            }
            
            // See `SingleValueEncodingContainer.encode(_:)`.
            mutating func encode(_ value: some Encodable) throws {
                /// If the coding path is not empty, we reached this point via a keyed container's
                /// `superEncoder(forKey:)`, so we want to encode the provided value for the given column directly,
                /// so that database-specific logic for handling arrays or other non-scalar values is in effect (i.e.
                /// this encoder never goes deeper than one level). This allows support for types such as Fluent's
                /// `Model`, whose `Encodable` conformance calls `superEncoder(forKey:).singleValueContainer()` for
                /// all properties. (That some of those properties do not properly encode in practice even with this
                /// support is a separate problem that does not concern SQLKit; this logic is here because it is
                /// technically required for a fully correct Codable implementation.)
                if let key = self.codingPath.last {
                    self.encoder.set(SQLBind(FakeSendableCodable(value)), forKey: key)
                }
                /// Otherwise, we reached this point via the top-level encoder's `singleValueContainer()`, and we want
                /// to recurse back into our own logic without triggering the "can't encode single values" failure
                /// mode right away. This enables support for types which encode an aggregate from inside a single-
                /// value container (or any number of layers of single-value containers, as long as there's an
                /// aggregate at the innermost layer). We avoid infinite recursion by implementing each of the various
                /// type-specifc `encode(_:)` methods such that they unconditionally fail (taking advantage of the
                /// knowledge that all encoding must eventually either encode nothing, call `encodeNil()`, or invoke
                /// one of the concrete `encode(_:)` methods).
                else {
                    try value.encode(to: self.encoder)
                }
            }

            /// See `encode<T>(_:)` above for why these are here.
            
            // See `SingleValueEncodingContainer.encode(_:)`.
            mutating func encode(_: Bool) throws   { throw .invalid(at: self.codingPath) }
            mutating func encode(_: String) throws { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Float) throws  { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Double) throws { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Int) throws    { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Int8) throws   { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Int16) throws  { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Int32) throws  { throw .invalid(at: self.codingPath) }
            mutating func encode(_: Int64) throws  { throw .invalid(at: self.codingPath) }
            mutating func encode(_: UInt) throws   { throw .invalid(at: self.codingPath) }
            mutating func encode(_: UInt8) throws  { throw .invalid(at: self.codingPath) }
            mutating func encode(_: UInt16) throws { throw .invalid(at: self.codingPath) }
            mutating func encode(_: UInt32) throws { throw .invalid(at: self.codingPath) }
            mutating func encode(_: UInt64) throws { throw .invalid(at: self.codingPath) }
        }
    }
}
