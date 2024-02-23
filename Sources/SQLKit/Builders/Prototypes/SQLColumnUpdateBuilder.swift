/// Builds column value assignment pairs for `UPDATE` queries.
///
///     builder.set("name", to: "Earth")
public protocol SQLColumnUpdateBuilder: AnyObject {
    /// List of assignment pairs.
    var values: [any SQLExpression] { get set }
}

extension SQLColumnUpdateBuilder {
    /// Encodes the given `Encodable` value to a sequence of key-value pairs and adds an assignment
    /// for each pair.
    @inlinable
    @discardableResult
    public func set(model: some Encodable & Sendable) throws -> Self {
        try self.set(model: model, prefix: nil, keyEncodingStrategy: .useDefaultKeys, nilEncodingStrategy: .default)
    }

    /// Encodes the given `Encodable` value to a sequence of key-value pairs and adds an assignment
    /// for each pair, allowing the caller to specify ``SQLQueryEncoder`` options.
    @inlinable
    @discardableResult
    public func set(
        model: some Encodable & Sendable,
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default
    ) throws -> Self {
        try self.set(
            model: model,
            with: .init(prefix: prefix, keyEncodingStrategy: keyEncodingStrategy, nilEncodingStrategy: nilEncodingStrategy)
        )
    }

    /// Encodes the given `Encodable` value to a sequence of key-value pairs and adds an assignment
    /// for each pair, allowing the caller to specify a preconfigured ``SQLQueryEncoder``.
    @inlinable
    @discardableResult
    public func set(
        model: some Encodable & Sendable,
        with encoder: SQLQueryEncoder
    ) throws -> Self {
        try encoder.encode(model).reduce(self) { $0.set(SQLColumn($1.0), to: $1.1) }
    }

    /// Add an assignment of the column with the given name to the provided bound value.
    @inlinable
    @discardableResult
    public func set(_ column: String, to bind: some Encodable & Sendable) -> Self {
        self.set(SQLColumn(column), to: SQLBind(bind))
    }
    
    /// Add an assignment of the column with the given name to the given expression.
    @inlinable
    @discardableResult
    public func set(_ column: String, to value: any SQLExpression) -> Self {
        self.set(SQLColumn(column), to: value)
    }
    
    /// Add an assignment of the given column to the provided bound value.
    @inlinable
    @discardableResult
    public func set(_ column: any SQLExpression, to bind: some Encodable & Sendable) -> Self {
        self.set(column, to: SQLBind(bind))
    }
    
    /// Add an assignment of the given column to the given expression.
    @inlinable
    @discardableResult
    public func set(_ column: any SQLExpression, to value: any SQLExpression) -> Self {
        self.values.append(SQLBinaryExpression(left: column, op: SQLBinaryOperator.equal, right: value))
        return self
    }
}
