/// A "nested subpath" expression is used to descend into the "deeper" structure of a non-scalar value,
/// such as a dictionary, array, or JSON value.
///
/// This expression is effectively an API for ``SQLDialect/nestedSubpathExpression(in:for:)-6lhiy``,
/// which is defined as providing an expression for descending specifically into JSON values only. As a
/// result, the more "general" usage of applying a nested subpath to _any_ non-scalar value is not
/// available via this interface.
public struct SQLNestedSubpathExpression: SQLExpression {
    /// The expression to which the nested subpath is applied.
    public var column: any SQLExpression
    
    /// The subpath itself. **Must** always contain at least one element.
    public var path: [String]
    
    /// Create a nested subpath from an expression and an array of one or more path elements.
    ///
    /// - Parameters:
    ///   - column: The expression to which the nested subpath applies.
    ///   - path: The subpath itself. If this array is empty, a runtime error occurs.
    public init(column: any SQLExpression, path: [String]) {
        assert(!path.isEmpty)
        
        self.column = column
        self.path = path
    }
    
    /// Create a nested subpath from an identifier string and an array of one or more path elements.
    ///
    /// - Parameters:
    ///   - column: A string to treat as an identifier to which the nested subpath applies.
    ///   - path: The subpath itself. If this array is empty, a runtime error occurs.
    public init(column: String, path: [String]) {
        self.init(column: SQLIdentifier(column), path: path)
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.dialect.nestedSubpathExpression(in: self.column, for: self.path)?.serialize(to: &serializer)
    }
}
