/// `RETURNING ...` statement.
///
public struct SQLReturning: SQLExpression {
    public var columns: [SQLExpression]

    public init(_ columns: [SQLExpression]) {
        self.columns = columns
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(" RETURNING ")
        SQLList(columns).serialize(to: &serializer)
    }
}
