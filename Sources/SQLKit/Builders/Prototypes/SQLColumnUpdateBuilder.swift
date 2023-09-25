/// Builds column value assignment pairs for `UPDATE` queries.
///
///     builder.set("name", to: "Earth")
public protocol SQLColumnUpdateBuilder: AnyObject {
    /// List of assignment pairs.
    var values: [any SQLExpression] { get set }
}

extension SQLColumnUpdateBuilder {
    /// Encodes the given ``Encodable`` value to a sequence of key-value pairs and adds an assignment
    /// for each pair.
    @inlinable
    @discardableResult
    public func set<E>(model: E) throws -> Self where E: Encodable {
        try SQLQueryEncoder().encode(model).reduce(self) { $0.set(SQLColumn($1.0), to: $1.1) }
    }
    
    /// Add an assignment of the column with the given name to the provided bound value.
    @inlinable
    @discardableResult
    public func set(_ column: String, to bind: any Encodable) -> Self {
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
    public func set(_ column: any SQLExpression, to bind: any Encodable) -> Self {
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
