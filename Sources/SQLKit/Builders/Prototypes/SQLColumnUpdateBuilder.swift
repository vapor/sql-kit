/// Common definitions for query builders which support assigning values to columns.
///
/// It is unspecified whether columns specified via this protocol are qualified or aliasable.
public protocol SQLColumnUpdateBuilder: AnyObject {
    /// List of assignment pairs.
    var values: [any SQLExpression] { get set }
}

extension SQLColumnUpdateBuilder {
    /// Using a default-configured ``SQLQueryEncoder``, transform the provided model into a series of key/value
    /// pairs and add an assignment for each pair.
    ///
    /// Column names are left unqualified.
    ///
    /// - Parameter model: An `Encodable` value whose keys and values will form a series of column assignments.
    @inlinable
    @discardableResult
    public func set(model: some Encodable & Sendable) throws -> Self {
        try self.set(model: model, with: .init())
    }

    /// Configure a new ``SQLQueryEncoder`` as specified, use it to transform the provided model into a series of
    /// key/value pairs, and add an assignment for each pair.
    ///
    /// Column names are left unqualified.
    ///
    /// - Parameters:
    ///   - model: An `Encodable` value whose keys and values will form a series of column assignments.
    ///   - prefix: See ``SQLQueryEncoder/prefix``.
    ///   - keyEncodingStrategy: See ``SQLQueryEncoder/keyEncodingStrategy-swift.property``.
    ///   - nilEncodingStrategy: See ``SQLQueryEncoder/nilEncodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLQueryEncoder/userInfo``.
    @inlinable
    @discardableResult
    public func set(
        model: some Encodable & Sendable,
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) throws -> Self {
        try self.set(
            model: model,
            with: .init(
                prefix: prefix,
                keyEncodingStrategy: keyEncodingStrategy,
                nilEncodingStrategy: nilEncodingStrategy,
                userInfo: userInfo
            )
        )
    }

    /// Using the given ``SQLQueryEncoder``, transform the provided model into a series of key/value pairs and add an
    /// assignment for each pair.
    ///
    /// Column names are left unqualified.
    ///
    /// - Parameters:
    ///   - model: An `Encodable` value whose keys and values will form a series of column assignments.
    ///   - encoder: A configured ``SQLQueryEncoder`` to use.
    @inlinable
    @discardableResult
    public func set(
        model: some Encodable & Sendable,
        with encoder: SQLQueryEncoder
    ) throws -> Self {
        try encoder.encode(model).reduce(self) { $0.set(SQLColumn($1.0), to: $1.1) }
    }

    /// Add an assignment setting the named column to the provided `Encodable` value.
    ///
    /// The column name is left unqualified.
    ///
    /// - Parameters:
    ///   - column: The name of the column whose value is to be set.
    ///   - bind: The value to assign to the named column.
    @inlinable
    @discardableResult
    public func set(_ column: String, to bind: any Encodable & Sendable) -> Self {
        self.set(SQLColumn(column), to: SQLBind(bind))
    }
    
    /// Add an assignment setting the named column to the provided expression.
    ///
    /// The column name is left unqualified.
    ///
    /// - Parameters:
    ///   - column: The name of the column whose value is to be set.
    ///   - value: The expression describing the value to assign to the named column.
    @inlinable
    @discardableResult
    public func set(_ column: String, to value: any SQLExpression) -> Self {
        self.set(SQLColumn(column), to: value)
    }
    
    /// Add an assignment setting the given column to the provided `Encodable` value.
    ///
    /// The column name is left unqualified.
    ///
    /// - Parameters:
    ///   - column: The column whose value is to be set.
    ///   - bind: The value to assign to the given column.
    @inlinable
    @discardableResult
    public func set(_ column: any SQLExpression, to bind: any Encodable & Sendable) -> Self {
        self.set(column, to: SQLBind(bind))
    }
    
    /// Add an assignment setting the given column to the provided expression.
    ///
    /// The column name is left unqualified.
    ///
    /// - Parameters:
    ///   - column: The column whose value is to be set.
    ///   - value: The expression describing the value to assign to the named column.
    @inlinable
    @discardableResult
    public func set(_ column: any SQLExpression, to value: any SQLExpression) -> Self {
        self.values.append(SQLColumnAssignment(setting: column, to: value))
        return self
    }
}
