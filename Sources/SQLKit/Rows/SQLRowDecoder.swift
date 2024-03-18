/// An implementation of `Decoder` designed to decode "models" (or, in general, aggregate `Decodable` types) from
/// ``SQLRow``s returned from a database query.
///
/// This type essentially acts as a bridge between `Codable` structure types and the per-column decoding methods
/// provided by ``SQLRow``. It is, somewhat confusingly, designed primarily for use via ``SQLQueryFetcher``'s
/// ``SQLQueryFetcher/all(decoding:)-5dt2x`` and ``SQLQueryFetcher/first(decoding:)-63noi`` methods, or somewhat more
/// directly via ``SQLRow/decode(model:prefix:keyDecodingStrategy:userInfo:)`` and ``SQLRow/decode(model:with:)``, but
/// it can also be manually invoked. For example:
///
/// ```swift
/// struct MySimpleUserModel: Codable {
///     var id: Int
///     var username: String
///     var passwordHash: [UInt8]
///     var email: String?
///     var createdAt: Date
/// }
///
/// let query = sqlDatabase.select()
///     .columns("id", "username", "password_hash", "email", "created_at")
///     .from("my_simple_users")
///
/// // Direct usage:
/// let rows = try await query.all()
/// let decoder = SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase)
/// let userModels = try rows.map { row in
///     try decoder.decode(MySimpleUserModel.self, from: row)
/// }
///
/// // Invoked via SQLRow:
/// let userModels = try rows.map { row in
///     try row.decode(MySimpleUserModel.self, keyDecodingStrategy: .convertFromSnakeCase)
/// }
///
/// // Invoked via SQLQueryFetcher:
/// let userModels = try await query.all(
///     decoding: MySimpleUserModel.self,
///     keyDecodingStrategy: .convertFromSnakeCase
/// )
/// ```
///
/// > Important: This API is designed for use with models in the generic sense, i.e. Swift structures which conform
/// > to `Codable`. It is _not_ designed to bridge between FluentKit's `Model` protocol and SQLKit methods; an attempt
/// > to do so will result in errors and/or unexpected behavior.
public struct SQLRowDecoder: Sendable {
    /// A strategy describing how to transform column names in a row to match the expectations of decoded type(s).
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

        /// Perform a user-specified conversion between keys in a query result row and the `CodingKey`s used by
        /// the decoded model type.
        ///
        /// The full path to the current decoding position is provided for context (in case you need to
        /// locate this key within the payload). The returned key is used in place of the last component
        /// in the coding path before decoding.
        ///
        /// If the result of the conversion is a duplicate key, then only one value will be present in the
        /// container for the type to decode from.
        ///
        /// > Note: The coding "path" will in reality always contain exactly one coding key. Users may consider
        /// > this an API guarantee and safely write code which relies on this assumption.
        ///
        /// > Warning: The naming conventions used by ``SQLRowDecoder/KeyDecodingStrategy-swift.enum`` are
        /// > misleading. In particular, although the ``convertFromSnakeCase`` strategy implies conversion
        /// > to camel-cased keys _from_ snake-cased originals, in reality any given `CodingKey` is subjected to
        /// > the inverse transformation (as described by
        /// > ``SQLQueryEncoder/KeyEncodingStrategy-swift.enum/convertToSnakeCase``). Likewise, the closure provided to
        /// > the ``custom(_:)`` strategy is expected to perform a _forward_ translation, translating a Swift-side
        /// > `CodingKey` into the database-side column name found in a given query result row. Users are encouraged
        /// > to consider the use of ``SomeCodingKey`` for returning results.
        /// >
        /// > It is also worth noting that this behavior is inconsistent with how a `KeyDecodingStrategy` specified
        /// > on Foundation's `JSONDecoder` works.
        ///
        /// - Parameter closure: A closure which performs a _forward_ conversion of a `CodingKey` to the equivalent
        ///   database column name.
        @preconcurrency
        case custom(@Sendable ([any CodingKey]) -> any CodingKey)
        
        /// Apply the strategy to the given coding key, returning the transformed result.
        ///
        /// > Note: As noted elsewhere, although the strategy implies performing _backwards_ translations (converting
        /// > database column names to coding keys), the actual operation of applying the strategy is identical to
        /// > that of ``SQLQueryEncoder/KeyEncodingStrategy-swift.enum`` - a _forward_ translation from coding keys to
        /// > database column names.
        fileprivate func apply(to key: some StringProtocol) -> String {
            switch self {
            case .useDefaultKeys:
                return .init(key)
            case .convertFromSnakeCase:
                return .init(key).convertedToSnakeCase // N.B.: NOT a typo!
            case .custom(let custom):
                return custom([String(key).codingKeyValue]).stringValue
            }
        }
    }

    /// A prefix to be applied to coding keys before interpreting them as column names.
    ///
    /// The ``prefix``, if set, is applied _after_ the ``keyDecodingStrategy-swift.property``.
    ///
    /// Example:
    ///
    /// Prefix|Strategy|Coding key|Column name
    /// -|-|-|-
    /// _nil_|``KeyDecodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`FooBar`
    /// `p`|``KeyDecodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`pFooBar`
    /// _nil_|``KeyDecodingStrategy-swift.enum/convertFromSnakeCase``|`FooBar`|`foo_bar`
    /// `p`|``KeyDecodingStrategy-swift.enum/convertFromSnakeCase``|`FooBar`|`pfoo_bar`
    public var prefix: String?
    
    /// The key decoding strategy to use.
    ///
    /// The ``prefix``, if set, is applied _after_ the ``keyDecodingStrategy-swift.property``.
    ///
    /// Example:
    ///
    /// Prefix|Strategy|Coding key|Column name
    /// -|-|-|-
    /// _nil_|``KeyDecodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`FooBar`
    /// `p`|``KeyDecodingStrategy-swift.enum/useDefaultKeys``|`FooBar`|`pFooBar`
    /// _nil_|``KeyDecodingStrategy-swift.enum/convertFromSnakeCase``|`FooBar`|`foo_bar`
    /// `p`|``KeyDecodingStrategy-swift.enum/convertFromSnakeCase``|`FooBar`|`pfoo_bar`
    public var keyDecodingStrategy: KeyDecodingStrategy
    
    /// User info to provide to the underlying `Decoder`.
    public var userInfo: [CodingUserInfoKey: any Sendable]

    /// Create a configured ``SQLRowDecoder``.
    ///
    /// - Parameters:
    ///   - prefix: The key prefix to use for column names. See ``prefix`` for details.
    ///   - keyDecodingStrategy: The strategy to use for translating column names to keys. See
    ///     ``keyDecodingStrategy-swift.property`` for details.
    ///   - userInfo: Key-value pairs to provide as user info to the underlying decoder.
    public init(
        prefix: String? = nil,
        keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) {
        self.prefix = prefix
        self.keyDecodingStrategy = keyDecodingStrategy
        self.userInfo = userInfo
    }

    /// Decode a value of type `T` from the given ``SQLRow``.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - row: The row containing the data to decode.
    /// - Returns: An instance of `type` decoded from `row`.
    /// - Throws: Any error which occurs during the decoding process.
    public func decode<T: Decodable>(_ type: T.Type, from row: some SQLRow) throws -> T {
        try T.init(from: SQLRowDecoderImpl(configuration: self, row: row))
    }

    /// Underlying implementation.
    private struct SQLRowDecoderImpl<Row: SQLRow>: Decoder {
        /// Holds configuration information for the decoding process.
        let configuration: SQLRowDecoder
        
        /// The row containing the data to be decoded.
        let row: Row
        
        // See `Decoder.codingPath`.
        var codingPath: [any CodingKey] = []
        
        // See `Decoder.userInfo`.
        var userInfo: [CodingUserInfoKey: Any] {
            self.configuration.userInfo
        }

        // See `Decoder.container(keyedBy:)`.
        func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
            /// If the coding path is not empty, we have reached this point via `superDecoder(forKey:)`, from which
            /// the only valid request is for a single-value container.
            guard self.codingPath.isEmpty else {
                throw .invalid(at: self.codingPath)
            }
            
            /// Otherwise, a keyed container request is valid.
            return .init(KeyedContainer(decoder: self))
        }
        
        // See `Decoder.unkeyedContainer()`.
        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            /// It is never valid to request an unkeyed container in the current implementation. In a design having
            /// differing public API, a row could be conceivably treated as an unkeyed container if accessed in terms
            /// of column indexes rather than column names.
            throw .invalid(at: self.codingPath)
        }
        
        // See `Decoder.singleValueContainer()`.
        func singleValueContainer() throws -> any SingleValueDecodingContainer {
            SingleValueContainer(decoder: self)
        }

        /// Apply the configured transformation to convert a given coding key to a column name.
        private func column(for key: String) -> String {
            "\(self.configuration.prefix ?? "")\(self.configuration.keyDecodingStrategy.apply(to: key))"
        }

        /// An implementation of `KeyedDecodingContainerProtocol` for ``SQLRowDecoderImpl``.
        private struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
            // See `KeyedDecodingContainerProtocol.codingPath`.
            var codingPath: [any CodingKey] {
                self.decoder.codingPath
            }
            
            /// The decoder which created this container.
            let decoder: SQLRowDecoderImpl

            // See `KeyedDecodingContainerProtocol.allKeys`.
            var allKeys: [Key] {
                /// Warning: This does not return accurate results! To be correct, each column name must have the
                /// configured key decoding strategy and key prefix applied to it _in reverse_, an operation which can
                /// not be reliably performed with the existing
                /// ``SQLRowDecoder/KeyDecodingStrategy-swift.enum/custom(_:)`` API. This implementation does the best
                /// it can with the given limitations.
                self.decoder.row.allColumns.map {
                    String($0.drop(prefix: self.decoder.configuration.prefix))
                }.map {
                    switch self.decoder.configuration.keyDecodingStrategy {
                    case .useDefaultKeys:
                        return $0
                    case .convertFromSnakeCase:
                        return $0.convertedFromSnakeCase
                    case .custom(_):
                        return $0 // this is inaccurate but there's little to be done about it
                    }
                }.compactMap(Key.init(stringValue:))
            }
            
            // See `KeyedDecodingContainerProtocol.contains(_:)`.
            func contains(_ key: Key) -> Bool {
                self.decoder.row.contains(column: self.decoder.column(for: key.stringValue))
            }
            
            // See `KeyedDecodingContainerProtocol.decodeNil(forKey:)`.
            func decodeNil(forKey key: Key) throws -> Bool {
                do {
                    /// Do _not_ check `contains(_:)` here; most often it will have already been called by the
                    /// default `decodeIfPresent(_:forKey:)` implementation, and even if not, we don't necessarily
                    /// want to make such a check.
                    return try self.decoder.row.decodeNil(column: self.decoder.column(for: key.stringValue))
                } catch let error as DecodingError {
                    /// Ensure that errors contain complete coding paths.
                    throw error.under(path: self.codingPath + [key])
                }
            }
            
            // See `KeyedDecodingContainerProtocol.decode(_:forKey:)`.
            func decode<T: Decodable>(_: T.Type, forKey key: Key) throws -> T {
                let column = self.decoder.column(for: key.stringValue)
                
                guard self.decoder.row.contains(column: column) else {
                    throw DecodingError.keyNotFound(key, .init(
                        codingPath: self.codingPath,
                        debugDescription: "No value associated with key \"\(key.stringValue)\" (as \"\(column)\")."
                    ))
                }
                do {
                    return try self.decoder.row.decode(column: column)
                } catch let error as DecodingError {
                    /// Ensure that errors contain complete coding paths.
                    throw error.under(path: self.codingPath + [key])
                }
            }
            
            // See `KeyedDecodingContainerProtocol.superDecoder(forKey:)`.
            func superDecoder(forKey key: Key) throws -> any Decoder {
                /// Return a valid decoder so that implementations which then decode scalar values from a
                /// single-value container may operate properly. Recursion back into the keyed container path is
                /// prevented by the check for an empty coding path in `container(keyedBy:)`.
                SQLRowDecoderImpl(
                    configuration: self.decoder.configuration,
                    row: self.decoder.row,
                    codingPath: self.codingPath + [key]
                )
            }

            // See `KeyedDecodingContainerProtocol.nestedContainer(keyedBy:forKey:)`.
            func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey key: Key) throws -> KeyedDecodingContainer<N> {
                /// Nested containers are never supported.
                throw .invalid(at: self.codingPath + [key])
            }
            
            // See `KeyedDecodingContainerProtocol.nestedUnkeyedContainer(forKey:)`.
            func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
                /// Neither nested nor unkeyed containers are supported.
                throw .invalid(at: self.codingPath + [key])
            }
            
            // See `KeyedDecodingContainerProtocol.superDecoder()`.
            func superDecoder() throws -> any Decoder {
                /// This method is ostensibly equivalent to `superDecoder(forKey: "super")`, but conceptually does not
                /// have the same meaning; its actual intent is not supported.
                throw .invalid(at: self.codingPath)
            }
        }

        /// An implementation of `SingleValueDecodingContainer` for ``SQLRowDecoderImpl``.
        private struct SingleValueContainer: SingleValueDecodingContainer {
            // See `SingleValueDecodingContainer.codingPath`.
            var codingPath: [any CodingKey] {
                self.decoder.codingPath
            }
            
            /// The decoder which created this container.
            let decoder: SQLRowDecoderImpl
            
            // See `SingleValueDecodingContainer.decodeNil()`.
            func decodeNil() -> Bool {
                if let key = self.codingPath.last {
                    /// This is the same path as the one described for the identical branch in `decode<T>(_:)`
                    /// immediately below; refer to that discussion for details about this logic, with the additional
                    /// remark that, as with the `else` branch, our inability to throw errors from this method forces
                    /// us to always assume non-`nil` and force calling code into a branch where we _can_ throw.
                    return (try? self.decoder.row.decodeNil(column: self.decoder.column(for: key.stringValue))) ?? false
                } else {
                    /// We would much prefer to be able to throw an error from here when the coding path is empty, but
                    /// ironically, while we _can_ throw from the equivalent encoding method, this is one of the only
                    /// places in the decoding infrastructure from which we cannot. By returning false we at least ensure
                    /// that the overwhelmingly most common way to reach this path - the [`Decodable` conformance of
                    /// `Optional`](optionaldecodable) - will be forced to fallback to `decode(_:)`, which will throw the
                    /// error we would have thrown here.
                    ///
                    /// [optionaldecodable]: https://github.com/apple/swift/blob/6a86bf34646a18cf7eb74f7bf7e1ae815bd97739/stdlib/public/core/Codable.swift#L5397
                    return false
                }
            }
            
            // See `SingleValueDecodingContainer.decode(_:)`.
            func decode<T: Decodable>(_: T.Type) throws -> T {
                /// If the coding path is not empty, we reached this point via a keyed container's
                /// `superDecoder(forKey:)`, so we want to decode the row's actual value for the given column directly,
                /// so that database-specific logic for handling arrays or other non-scalar values is in effect (i.e.
                /// this decoder never goes deeper than one level). This allows support for types such as Fluent's
                /// `Model`, whose `Decodable` conformance calls `superDecoder(forKey:).singleValueContainer()` for all
                /// properties. (That some of those properties do not properly decode in practice even with this
                /// support is a separate problem that does not concern SQLKit; this logic is here because it is
                /// technically required for a fully correct Codable implementation.)
                if let key = self.codingPath.last {
                    do {
                        return try self.decoder.row.decode(column: self.decoder.column(for: key.stringValue))
                    } catch let error as DecodingError {
                        /// Ensure that errors contain complete coding paths.
                        throw error.under(path: self.codingPath + [key])
                    }
                }
                /// Otherwise, we reached this point via the top-level decoder's `singleValueContainer()`, and we want
                /// to recurse back into our own logic without triggering the "can't decode single values" failure
                /// mode right away. This enables support for types which decode an aggregate from inside a single-
                /// value container (or any number of layers of single-value containers, as long as there's an
                /// aggregate at the innermost layer). We avoid infinite recursion by implementing each of the various
                /// type-specifc `decode(_:)` methods such that they unconditionally fail (taking advantage of the
                /// knowledge that all decoding must eventually either decode nothing, call `decodeNil()`, or invoke
                /// one of the concrete `decode(_:)` methods).
                else {
                    return try T.init(from: self.decoder)
                }
            }

            /// See `decode<T>(_:)` above for why these are here.
            
            // See `SingleValueDecodingContainer.decode(_:)`.
            func decode(_: Bool.Type) throws -> Bool     { throw .invalid(at: self.codingPath) }
            func decode(_: String.Type) throws -> String { throw .invalid(at: self.codingPath) }
            func decode(_: Float.Type) throws -> Float   { throw .invalid(at: self.codingPath) }
            func decode(_: Double.Type) throws -> Double { throw .invalid(at: self.codingPath) }
            func decode(_: Int.Type) throws -> Int       { throw .invalid(at: self.codingPath) }
            func decode(_: Int8.Type) throws -> Int8     { throw .invalid(at: self.codingPath) }
            func decode(_: Int16.Type) throws -> Int16   { throw .invalid(at: self.codingPath) }
            func decode(_: Int32.Type) throws -> Int32   { throw .invalid(at: self.codingPath) }
            func decode(_: Int64.Type) throws -> Int64   { throw .invalid(at: self.codingPath) }
            func decode(_: UInt.Type) throws -> UInt     { throw .invalid(at: self.codingPath) }
            func decode(_: UInt8.Type) throws -> UInt8   { throw .invalid(at: self.codingPath) }
            func decode(_: UInt16.Type) throws -> UInt16 { throw .invalid(at: self.codingPath) }
            func decode(_: UInt32.Type) throws -> UInt32 { throw .invalid(at: self.codingPath) }
            func decode(_: UInt64.Type) throws -> UInt64 { throw .invalid(at: self.codingPath) }
        }
    }
}
