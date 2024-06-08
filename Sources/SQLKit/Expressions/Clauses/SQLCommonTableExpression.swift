/// A clause describing a single Common Table Expressions, which in itws simplest form provides
/// additional data to a primary query in the same way as joining to a subquery.
///
/// > Note: There is no ``SQLDialect`` flag for CTE support, as CTEs are supported by all of the
/// > databases for which first-party drivers exist at the time of this writing (although they are
/// > not available in MySQL 5.7, which is long since EOL and should not be in use by anyone anymore).
public struct SQLCommonTableExpression: SQLExpression {
    /// Indicates whether the CTE is recursive, e.g. whether its query is a `UNION` whose second subquery
    /// refers to the CTE's own aliased name.
    ///
    /// > Warning: Neither ``SQLCommonTableExpression`` nor the methods of ``SQLCommonTableExpressionBuilder``
    /// > validate that a recursive CTE's query takes the proper form, nor that a non-recursive CTE's query
    /// > is not self-referential. It is the responsibility of the user to specify the flag accurately. Failure
    /// > to do so will result in generating invalid SQL.
    public var isRecursive: Bool = false
    
    /// The name used to refer to the CTE's data.
    public var alias: any SQLExpression
    
    /// A list of column names yielded by the CTE. May be empty.
    public var columns: [any SQLExpression] = []
    
    /// The subquery which yields the CTE's data.
    public var query: any SQLExpression
    
    /// Create a new Common Table Expression.
    /// 
    /// - Parameters:
    ///   - alias: Specifies the name to be used to refer to the CTE.
    ///   - query: The subquery which yields the CTE's data.
    public init(alias: some SQLExpression, query: some SQLExpression) {
        self.alias = alias
        self.query = query
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            /// The ``SQLCommonTableExpression/isRecursive`` flag is not used in this logic. This is not an
            /// oversight. CTE syntax requires that `RECURSIVE` be specified as part of the overall `WITH`
            /// clause, rather on a per-CTE basis. As such, the recursive flag is handled by the serialization
            /// logic of ``SQLCommonTableExpressionGroup``.
            $0.append(self.alias)
            if !self.columns.isEmpty {
                $0.append(SQLGroupExpression(self.columns))
            }
            if let subqueryExpr = self.query as? SQLSubquery {
                $0.append("AS", subqueryExpr)
            } else if let subqueryExpr = self.query as? SQLUnionSubquery {
                $0.append("AS", subqueryExpr)
            } else if let groupExpr = self.query as? SQLGroupExpression {
                $0.append("AS", groupExpr)
            } else {
                $0.append("AS", SQLGroupExpression(self.query))
            }
        }
    }
}

/// A clause representing a group of one or more ``SQLCommonTableExpression``s.
///
/// This expression makes up a complete `WITH` clause in the generated SQL, serving to centralize the
/// serialization logic for such a clause in a single location rather than requiring it to be repeated
/// by every query type that supports CTEs.
public struct SQLCommonTableExpressionGroup: SQLExpression {
    /// The list of common table expressions which make up the group.
    ///
    /// Must contain at least one expression. If the list is empty, invalid SQL will be generated.
    public var tableExpressions: [any SQLExpression]
    
    public init(tableExpressions: [any SQLExpression]) {
        self.tableExpressions = tableExpressions
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("WITH")
            if self.tableExpressions.contains(where: { ($0 as? SQLCommonTableExpression)?.isRecursive ?? false }) {
                $0.append("RECURSIVE")
            }
            $0.append(SQLList(self.tableExpressions))
        }
    }
}
