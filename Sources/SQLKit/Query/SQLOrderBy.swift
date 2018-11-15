/// `ORDER BY` clause.
public protocol SQLOrderBy: SQLSerializable {
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// See `SQLDirection`.
    associatedtype Direction: SQLDirection
    
    /// Creates a new `SQLOrderBy`.
    static func orderBy(_ expression: Expression, _ direction: Direction) -> Self
}
