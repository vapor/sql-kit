/// A call to a function available in SQL, expressed as a name and a (possibly empty) list of arguments.
///
/// Example usage:
///
/// ```swift
/// try await sqlDatabase.select()
///     .column(SQLFunction("coalesce", args: SQlColumn("col1"), SQlColumn("col2"), SQLBind(defaultValue)))
///     .from("table")
///     .all()
/// ```
///
/// > Note: ``SQLFunction`` is permitted to substitute function names during serialization based on the current
/// > dialect if a known, unambiguous replacement for an unavailable name is available. At the time of this writing,
/// > no such substitutions take place in practice, but it would be of obvious utility in certain common cases, such
/// > as SQLite's lack of support for the `NOW()` function.
public struct SQLFunction: SQLExpression {
    /// The function's name.
    ///
    /// In this version of SQLKit, function names are always emitted as raw unquoted SQL.
    public let name: String
    
    /// The list of function arguments. May be empty.
    public let args: [any SQLExpression]
    
    /// Create a function from a name and list of arguments.
    ///
    /// Each argument is treated as a quotable identifier, _not_ raw SQL or a string literal.
    ///
    /// - Parameters:
    ///   - name: The function name.
    ///   - args: The list of arguments.
    @inlinable
    public init(_ name: String, args: String...) {
        self.init(name, args: args.map { SQLIdentifier($0) })
    }
    
    /// Create a function from a name and list of arguments.
    ///
    /// Each argument is treated as a quotable identifier, _not_ raw SQL or a string literal.
    ///
    /// - Parameters:
    ///   - name: The function name.
    ///   - args: The list of arguments.
    @inlinable
    public init(_ name: String, args: [String]) {
        self.init(name, args: args.map { SQLIdentifier($0) })
    }
    
    /// Create a function from a name and list of arguments.
    ///
    /// - Parameters:
    ///   - name: The function name.
    ///   - args: The list of arguments.
    @inlinable
    public init(_ name: String, args: any SQLExpression...) {
        self.init(name, args: args)
    }
    
    /// Create a function from a name and list of arguments.
    ///
    /// - Parameters:
    ///   - name: The function name.
    ///   - args: The list of arguments.
    @inlinable
    public init(_ name: String, args: [any SQLExpression] = []) {
        self.name = name
        self.args = args
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.name)
        SQLGroupExpression(self.args).serialize(to: &serializer)
    }
}

extension SQLFunction {
    /// A factory method to simplify use of the standard `COALESCE()` function.
    ///
    /// The SQL `COALESCE()` function takes one or more arguments, and returns the first such arguments which passes
    /// an `IS NOT NULL` test. If all arguments evaluate to `NULL`, `NULL` is returned.
    ///
    /// Example:
    ///
    /// ```swift
    /// try await database.select()
    ///     .column(SQLFunction.coalesce(SQLColumn("col1"), SQLBind(defaultValue)))
    ///     .all()
    /// ```
    ///
    /// - Parameter exprs: A list of expressions to coalesce.
    /// - Returns: An appropriately-constructed ``SQLFunction``.
    @inlinable
    public static func coalesce(_ exprs: any SQLExpression...) -> SQLFunction {
        self.coalesce(exprs)
    }

    /// A factory method to simplify use of the standard `COALESCE()` function.
    ///
    /// The SQL `COALESCE()` function takes one or more arguments, and returns the first such arguments which passes
    /// an `IS NOT NULL` test. If all arguments evaluate to `NULL`, `NULL` is returned.
    ///
    /// Example:
    ///
    /// ```swift
    /// try await database.select()
    ///     .column(SQLFunction.coalesce(SQLColumn("col1"), SQLBind(defaultValue)))
    ///     .all()
    /// ```
    ///
    /// - Parameter exprs: A list of expressions to coalesce.
    /// - Returns: An appropriately-constructed ``SQLFunction``.
    @inlinable
    public static func coalesce(_ expressions: [any SQLExpression]) -> SQLFunction {
        .init("COALESCE", args: expressions)
    }
}
