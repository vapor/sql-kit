/// Builds column value assignment pairs for `UPDATE` queries.
///
///     builder.set("name", to: "Earth")
public protocol SQLColumnUpdateBuilder: AnyObject {
    /// List of assignment pairs that have been built.
    var values: [SQLExpression] { get set }
}

extension SQLColumnUpdateBuilder {
    /// Encodes the given `Encodable` value to a sequence of key-value pairs and adds an assignment
    /// for each pair.
    @discardableResult
    public func set<E>(model: E) throws -> Self where E: Encodable {
        return try SQLQueryEncoder().encode(model).reduce(self) { $0.set(SQLColumn($1.0), to: $1.1) }
    }
    
    /// Add an assignment of the column with the given name to the provided bound value.
    @discardableResult
    public func set(_ column: String, to bind: Encodable) -> Self {
        return self.set(SQLColumn(column), to: SQLBind(bind))
    }
    
    /// Add an assignment of the column with the given name to the given expression.
    @discardableResult
    public func set(_ column: String, to value: SQLExpression) -> Self {
        return self.set(SQLColumn(column), to: value)
    }
    
    /// Add an assignment of the given column to the provided bound value.
    @discardableResult
    public func set(_ column: SQLExpression, to bind: Encodable) -> Self {
        return self.set(column, to: SQLBind(bind))
    }
    
    /// Add an assignment of the given column to the given expression.
    @discardableResult
    public func set(_ column: SQLExpression, to value: SQLExpression) -> Self {
        self.values.append(SQLBinaryExpression(left: column, op: SQLBinaryOperator.equal, right: value))
        return self
    }
}
