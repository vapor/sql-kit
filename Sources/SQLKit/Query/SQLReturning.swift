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
        guard serializer.dialect.supportsReturning else {
            serializer.database.logger.warning("\(serializer.dialect.name) does not support 'RETURNING' clause, skipping.")
            return
        }

        guard !columns.isEmpty else { return }

        serializer.statement {
            $0.append("RETURNING")
            $0.append(SQLList(columns))
        }
    }
}
