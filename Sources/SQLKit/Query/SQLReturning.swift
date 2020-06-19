/// `RETURNING ...` statement.
///
public struct SQLReturning: SQLExpression {
    public var columns: [SQLExpression]

    /// Creates a new `SQLReturning`.
    public init(_ column: SQLColumn) {
        self.columns = [column]
    }

    /// Creates a new `SQLReturning`.
    public init(_ columns: [SQLExpression]) {
        self.columns = columns
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("RETURNING")
            $0.append(SQLList(columns))
        }
    }
}
