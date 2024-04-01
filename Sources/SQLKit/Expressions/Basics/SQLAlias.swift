///  Encapsulates SQL's `<expression> [AS] <name>` syntax, most often used to declare aliaed names
///  for columns and tables.
public struct SQLAlias: SQLExpression {
    /// The ``SQLExpression`` to alias.
    public var expression: any SQLExpression
    
    /// The alias itself.
    public var alias: any SQLExpression
    
    /// Create an alias expression from an expression and an alias expression.
    ///
    /// - Parameters:
    ///   - expression: The expression to alias.
    ///   - alias: The alias itself.
    @inlinable
    public init(_ expression: any SQLExpression, as alias: any SQLExpression) {
        self.expression = expression
        self.alias = alias
    }
    
    /// Create an alias expression from an expression and an alias name.
    ///
    /// - Parameters:
    ///   - expression: The expression to alias.
    ///   - alias: The aliased name.
    @inlinable
    public init(_ expression: any SQLExpression, as alias: String) {
        self.init(expression, as: SQLIdentifier(alias))
    }

    /// Create an alias expression from a name and an alias name.
    ///
    /// - Parameters:
    ///   - name: The name to alias.
    ///   - alias: The aliased name.
    @inlinable
    public init(_ name: String, as alias: String) {
        self.init(SQLIdentifier(name), as: SQLIdentifier(alias))
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.expression)
            $0.append("AS", self.alias)
        }
    }
}
