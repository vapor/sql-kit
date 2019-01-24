/// `ORDER BY` clause.
public struct SQLOrderBy: SQLExpression {
    public var expression: SQLExpression
    
    public var direction: SQLExpression
    
    /// Creates a new `SQLOrderBy`.
    public init(expression: SQLExpression, direction: SQLExpression) {
        self.expression = expression
        self.direction = direction
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.expression.serialize(to: &serializer)
        serializer.write(" ")
        self.direction.serialize(to: &serializer)
    }
}

public enum SQLDirection: SQLExpression {
    case ascending
    case descending
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .ascending:
            serializer.write("ASC")
        case .descending:
            serializer.write("DESC")
        }
    }
}
