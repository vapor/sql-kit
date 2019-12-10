/// Builds `SQLExpression` joins, i.e., `JOIN` clauses.
///
///     builder.where(\Planet.name == "Earth")
///
public protocol SQLJoinBuilder: class {
    /// Expression being built.
    var joins: [SQLExpression] { get set }
}

extension SQLJoinBuilder {

    /// Joins a table
    ///
    ///     builder.join(method: .inner
    ///                  table: "galaxies",
    ///                  from: SQLColumn("galaxyID", table: "planets"),
    ///                  to: SQLColumn("id", table: "galaxys"))
    ///
    public func join(method: SQLJoinMethod = .inner, table: String, from: SQLColumn, to: SQLColumn) -> Self {
        self.joins.append(SQLJoin.init(method: method,
                         table: SQLIdentifier(table),
                         expression: SQLBinaryExpression(left: from, op: SQLBinaryOperator.equal, right: to)
        ))
        return self
    }


    /// Joins a table
    ///
    ///     builder.join(method: .inner
    ///                  table: SQLTableIdentifier("galaxies"),
    ///                  expression: SQLJoinBinaryExpression(from: SQLColumn("galaxyID", table: "planets"),
    ///                                                      to: SQLColumn("id", table: "galaxys")))
    ///
    public func join(method: SQLJoinMethod = .inner, table: SQLIdentifier, expression: SQLBinaryExpression) -> Self {
        self.joins.append(SQLJoin.init(method: method, table: table, expression: expression))
        return self
    }
}
