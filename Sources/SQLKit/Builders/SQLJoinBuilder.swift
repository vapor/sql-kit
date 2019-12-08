/// Builds `SQLExpression` joins, i.e., `JOIN` clauses.
///
///     builder.where(\Planet.name == "Earth")
///
public protocol SQLJoinBuilder: class {
    /// Expression being built.
    var joins: [SQLExpression] { get set }
}

extension SQLJoinBuilder {

    public func join(method: SQLJoinMethod, table: String, from: SQLColumn, to: SQLColumn) -> Self {
        self.joins.append(SQLJoin.init(method: method,
                                       table: SQLTableIdentifier(table),
                                       expression: SQLJoinBinaryExpression.init(from: from, to: to)))
        return self
    }


    /// Adds an expression to the `Join`
    ///
    ///     builder.join(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added to the predicate.
    public func join(method: SQLJoinMethod, table: SQLTableIdentifier, expression: SQLJoinBinaryExpression) -> Self {
        self.joins.append(SQLJoin.init(method: method, table: table, expression: expression))
        return self
    }
}
