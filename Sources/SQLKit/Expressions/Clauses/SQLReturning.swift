/// A clause describing a list of values to be returned from a data-modifying query.
///
/// Most - though not all - dialects support `RETURNING` clauses for DML queries such as `INSERT`, `UPDATE`, and
/// `DELETE`. This clause will not emit any SQL if the dialect reports lacking this support.
///
/// This clause is the building block underlying ``SQLReturningBuilder``.
public struct SQLReturning: SQLExpression {
    /// The list of columns to be returned.
    ///
    /// If empty, the expression does not serialize any content.
    public var columns: [any SQLExpression]

    /// Create a new returning-values clause.
    ///
    /// - Parameter column: A single column to return from a query.
    @inlinable
    public init(_ column: SQLColumn) {
        self.init([column])
    }

    /// Creates a new returning-values clause.
    ///
    /// - Parameter columns: One or more columns to return from a query.
    @inlinable
    public init(_ columns: [any SQLExpression]) {
        self.columns = columns
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        guard serializer.dialect.supportsReturning else {
            /// This logging can be a bit noisy for MySQL users, elide it for now.
            //serializer.database.logger.debug("\(serializer.dialect.name) does not support 'RETURNING' clause, skipping.")
            return
        }

        guard !self.columns.isEmpty else {
            return
        }

        serializer.statement {
            $0.append("RETURNING", SQLList(self.columns))
        }
    }
}
