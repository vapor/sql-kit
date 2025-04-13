/// Common definitions for query builders which support Common Table Expressions.
public protocol SQLCommonTableExpressionBuilder: AnyObject {
    /// An optional group of common table expressions to include in the query under construction.
    var tableExpressionGroup: SQLCommonTableExpressionGroup? { get set }
}

extension SQLCommonTableExpressionBuilder {
    // MARK: - String name, string columns
    
    /// Specify a subquery to include as a common table expression, for use elsewhere in the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with("c", columns: ["a"], as: SQLSubquery.select {$0
    ///         .column("x")
    ///         .from("table3")
    ///     })
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("a", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a non-recursive CTE's query is not self-referential. It is the responsibility of the user to invoke
    /// > the appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE, usually a `SELECT` query.
    @inlinable
    @discardableResult
    public func with(_ name: some StringProtocol, columns: [String], as query: some SQLExpression) -> Self {
        self.with(name, columns: columns.map(SQLIdentifier.init(_:)), as: query)
    }

    /// Specify a subquery to include as a _recursive_ common table expression, for use elsewhere in
    /// the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with(recursive: "c", columns: ["n"], as: SQLSubquery
    ///         .union { $0.column(SQLBind("1"), as: "n") }
    ///         .union(all: { $0
    ///             .column(SQLBinaryExpression("n", .add, 1))
    ///             .from("c").where("n", .lessThan, 3)
    ///         }).finish())
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("n", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a recursive CTE's query takes the proper form. It is the responsibility of the user to invoke the
    /// > appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE. For a recursive CTE, this must be an
    ///     expression representing at least one `SELECT` statement which does _not_ refer to the CTE and at least
    ///     one `UNION ALL` or `UNION DISTINCT` clause terminating with a `SELECT` statement which explicitly refers
    ///     to the CTE itself.
    @inlinable
    @discardableResult
    public func with(recursive name: some StringProtocol, columns: [String], as query: some SQLExpression) -> Self {
        self.with(recursive: name, columns: columns.map(SQLIdentifier.init(_:)), as: query)
    }

    // MARK: - String name, expression columns
    
    /// Specify a subquery to include as a common table expression, for use elsewhere in the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with("c", columns: ["a"], as: SQLSubquery.select {$0
    ///         .column("x")
    ///         .from("table3")
    ///     })
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("a", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a non-recursive CTE's query is not self-referential. It is the responsibility of the user to invoke
    /// > the appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE, usually a `SELECT` query.
    @inlinable
    @discardableResult
    public func with(_ name: some StringProtocol, columns: [any SQLExpression] = [], as query: some SQLExpression) -> Self {
        self.with(SQLIdentifier(String(name)), columns: columns, as: query)
    }

    /// Specify a subquery to include as a _recursive_ common table expression, for use elsewhere in
    /// the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with(recursive: "c", columns: ["n"], as: SQLSubquery
    ///         .union { $0.column(SQLBind("1"), as: "n") }
    ///         .union(all: { $0
    ///             .column(SQLBinaryExpression("n", .add, 1))
    ///             .from("c").where("n", .lessThan, 3)
    ///         }).finish())
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("n", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a recursive CTE's query takes the proper form. It is the responsibility of the user to invoke the
    /// > appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE. For a recursive CTE, this must be an
    ///     expression representing at least one `SELECT` statement which does _not_ refer to the CTE and at least
    ///     one `UNION ALL` or `UNION DISTINCT` clause terminating with a `SELECT` statement which explicitly refers
    ///     to the CTE itself.
    @inlinable
    @discardableResult
    public func with(recursive name: some StringProtocol, columns: [any SQLExpression] = [], as query: some SQLExpression) -> Self {
        self.with(recursive: SQLIdentifier(String(name)), columns: columns, as: query)
    }

    // MARK: - Expression name, string columns
    
    /// Specify a subquery to include as a common table expression, for use elsewhere in the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with("c", columns: ["a"], as: SQLSubquery.select {$0
    ///         .column("x")
    ///         .from("table3")
    ///     })
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("a", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a non-recursive CTE's query is not self-referential. It is the responsibility of the user to invoke
    /// > the appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE, usually a `SELECT` query.
    @inlinable
    @discardableResult
    public func with(_ name: some SQLExpression, columns: [String], as query: some SQLExpression) -> Self {
        self.with(name, columns: columns.map(SQLIdentifier.init(_:)), as: query)
    }

    /// Specify a subquery to include as a _recursive_ common table expression, for use elsewhere in
    /// the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with(recursive: "c", columns: ["n"], as: SQLSubquery
    ///         .union { $0.column(SQLBind("1"), as: "n") }
    ///         .union(all: { $0
    ///             .column(SQLBinaryExpression("n", .add, 1))
    ///             .from("c").where("n", .lessThan, 3)
    ///         }).finish())
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("n", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a recursive CTE's query takes the proper form. It is the responsibility of the user to invoke the
    /// > appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE. For a recursive CTE, this must be an
    ///     expression representing at least one `SELECT` statement which does _not_ refer to the CTE and at least
    ///     one `UNION ALL` or `UNION DISTINCT` clause terminating with a `SELECT` statement which explicitly refers
    ///     to the CTE itself.
    @inlinable
    @discardableResult
    public func with(recursive name: some SQLExpression, columns: [String], as query: some SQLExpression) -> Self {
        self.with(recursive: name, columns: columns.map(SQLIdentifier.init(_:)), as: query)
    }

    // MARK: - Expression name, expression columns
    
    /// Specify a subquery to include as a common table expression, for use elsewhere in the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with("c", columns: ["a"], as: SQLSubquery.select {$0
    ///         .column("x")
    ///         .from("table3")
    ///     })
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("a", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a non-recursive CTE's query is not self-referential. It is the responsibility of the user to invoke
    /// > the appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE, usually a `SELECT` query.
    @inlinable
    @discardableResult
    public func with(_ name: some SQLExpression, columns: [any SQLExpression] = [], as query: some SQLExpression) -> Self {
        self.with(isRecursive: false, name: name, columns: columns, as: query)
    }

    /// Specify a subquery to include as a _recursive_ common table expression, for use elsewhere in
    /// the overall query.
    ///
    /// Example usage:
    /// ```swift
    /// try await sqlDatabase.update("table1")
    ///     .with(recursive: "c", columns: ["n"], as: SQLSubquery
    ///         .union { $0.column(SQLBind("1"), as: "n") }
    ///         .union(all: { $0
    ///             .column(SQLBinaryExpression("n", .add, 1))
    ///             .from("c").where("n", .lessThan, 3)
    ///         }).finish())
    ///     .set("foo", to: "bar")
    ///     .where("foo", .equal, SQLColumn("n", table: "c"))
    ///     .run()
    /// ```
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_
    /// > validate that a recursive CTE's query takes the proper form. It is the responsibility of the user to
    /// > invoke the appropriate variant of this method. Failure to do so will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE. For a recursive CTE, this must be an
    ///     expression representing at least one `SELECT` statement which does _not_ refer to the CTE and at least
    ///     one `UNION ALL` or `UNION DISTINCT` clause terminating with a `SELECT` statement which explicitly refers
    ///     to the CTE itself.
    @inlinable
    @discardableResult
    public func with(recursive name: some SQLExpression, columns: [any SQLExpression] = [], as query: some SQLExpression) -> Self {
        self.with(isRecursive: true, name: name, columns: columns, as: query)
    }

    // MARK: - Funnel

    /// Specify a potentially-recursive common table expression for use elsewhere in a query.
    ///
    /// This is the common "funnel" method invoked by all other methods provided by
    /// ``SQLCommonTableExpressionBuilder``. Most users will not need to call this method directly.
    ///
    /// See ``with(_:columns:as:)-28k4r`` and ``with(recursive:columns:as:)-6yef`` for usage examples.
    ///
    /// > Warning: As with ``SQLCommonTableExpression``, ``SQLCommonTableExpressionBuilder`` does _NOT_ validate
    /// > that a recursive CTE's query takes the proper form, nor that a non-recursive CTE's query is not
    /// > self-referential. It is the responsibility of the user to specify the flag accurately. Failure to do so
    /// > will result in generating invalid SQL.
    ///
    /// - Parameters:
    ///   - isRecursive: Specifies whether or not the CTE is recursive.
    ///   - name: The name to assign to the query's results.
    ///   - columns: An optional list of unqualified column names to use for referencing the query's results.
    ///     If no column names are provided, the names are inferred from the query. If column names are provided,
    ///     the number of names provided must match the number of columns returned by the query.
    ///   - query: An expression which provides the contents of the CTE. If the CTE is recursive, this must be an
    ///     expression representing at least one `SELECT` statement which does _not_ refer to the CTE and at least
    ///     one `UNION ALL` or `UNION DISTINCT` clause terminating with a `SELECT` statement which explicitly refers
    ///     to the CTE itself.
    @inlinable
    @discardableResult
    public func with(
        isRecursive: Bool,
        name: some SQLExpression,
        columns: [any SQLExpression] = [],
        as query: some SQLExpression
    ) -> Self {
        var expression = SQLCommonTableExpression(alias: name, query: query)
        expression.isRecursive = isRecursive
        expression.columns = columns
        
        if self.tableExpressionGroup != nil {
            self.tableExpressionGroup?.tableExpressions.append(expression)
        } else {
            self.tableExpressionGroup = .init(tableExpressions: [expression])
        }
        return self
    }
}
