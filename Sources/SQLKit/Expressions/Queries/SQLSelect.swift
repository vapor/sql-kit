/// An expression representing a `SELECT` query. Used to retrieve rows and expression results from a database.
///
/// ```sql
/// SELECT
/// DISTINCT
///     "table1"."column1", "table2"."column2", COUNT("table3"."column3") AS "count"
/// FROM
///     "table1"
///     INNER JOIN "table2" ON "table1"."id"="table2"."table1_id"
///     LEFT JOIN "table3" ON "table2"."id"="table3"."table2_id"
/// WHERE
///     "table1"."column1"!=$0
/// GROUP BY
///     "table2"."column2", "table3"."column3"
/// HAVING
///     "table2"."column2"=$1
/// ORDER BY
///     "table1"."column1"
/// LIMIT 10, 20
/// LOCK IN SHARE MODE
/// ```
///
/// > Note: In any given SQL dialect, `SELECT` is all but universally the most complex of all queries, offering more
/// > variations and features within and between dialects than almost any other self-contained SQL statement.
/// > Accordingly, even more so than with other queries, SQLKit cannot hope to offer more than a baseline of common
/// > functionality. Some of the more obvious omissions in this version of the package include the `WINDOW` clause,
/// > the `INTO` (MySQL) or `AS` (Postgres) clauses, and Common Table Expressions (the `WITH` clause); support for
/// > most or all of these is under consideration for SQLKit's next major version.
///
/// See ``SQLSelectBuilder``.
public struct SQLSelect: SQLExpression {
    /// One or more expessions describing the data to retrieve from the database.
    public var columns: [any SQLExpression] = []
    
    /// One or more tables to include as sources for data to retrieve.
    ///
    /// This array rarely contains more than one element; when multiple tables are specified by this property, they
    /// are included in the resulting query via the comma operator, effectively creating a `CROSS JOIN` (Cartesian
    /// product); if not filtered by the ``predicate``, this can result in extremely slow and expensive queries. It
    /// is almost always preferable to specify all but the first source table in the ``joins`` array.
    public var tables: [any SQLExpression] = []
    
    /// If `true`, final result rows are deduplicated before being returned.
    ///
    /// `DISTINCT` processing occurs after all other processing, except `LIMIT`. Be aware that deduplication occurs
    /// across _entire_ rows, not any single field. There is no support for PostgreSQL's `DISTINCT ON` syntax at
    /// this time.
    public var isDistinct: Bool = false
    
    /// Zero or more joins to apply to the overall data sources.
    ///
    /// These will almost ways be instances of ``SQLJoin``.
    public var joins: [any SQLExpression] = []
    
    /// If not `nil`, an expression which filters the source data to determine the result rows.
    ///
    /// This corresponds to a `SELECT` query's `WHERE` clause and applies _before_ any `GROUP BY` clause(s). Most
    /// often the predicate will consist of one or more nested ``SQLBinaryExpression``s.
    public var predicate: (any SQLExpression)? = nil
    
    /// Zero or more columns or expressions specifying grouping keys for the filtered result rows.
    ///
    /// This corresponds to a `SELECT` query's `GROUP BY` clause.
    public var groupBy: [any SQLExpression] = []

    /// Like ``predicate``, but specifies filtering which applies _after_ ``groupBy`` keys are processed.
    ///
    /// `HAVING` clauses tend to be inefficient.
    public var having: (any SQLExpression)? = nil

    /// Zero or more columns or expressions specifying sort keys and directionalities for the filtered result rows.
    ///
    /// The order in which an `ORDER BY` clause takes effect is complex and varies between dialects.
    ///
    /// See ``SQLDirection``.
    public var orderBy: [any SQLExpression] = []
    
    /// If not `nil`, limits the number of result rows returned. Applies _after_ ``offset`` (if specified).
    ///
    /// Although the type of this property is `Int`, it is invalid to specify a negative value.
    public var limit: Int? = nil
    
    /// If not `nil`, skips the given number of result rows before starting to return results.
    ///
    /// Although the type of this property is `Int`, it is invalid to specify a negative value.
    public var offset: Int? = nil
    
    /// If not `nil`, specifies a locking clause which applies to the rows looked up by the query.
    ///
    /// See ``SQLLockingClause``.
    public var lockingClause: (any SQLExpression)? = nil
    
    /// Create a new data retrieval query.
    @inlinable
    public init() {}
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("SELECT")
            if self.isDistinct {
                $0.append("DISTINCT")
            }
            $0.append(SQLList(self.columns))
            $0.append("FROM", SQLList(self.tables))
            $0.append(SQLList(self.joins, separator: SQLRaw(" ")))
            if self.predicate != nil {
                $0.append("WHERE", self.predicate)
            }
            if !self.groupBy.isEmpty {
                $0.append("GROUP BY", SQLList(self.groupBy))
            }
            if self.having != nil {
                $0.append("HAVING", self.having)
            }
            if !self.orderBy.isEmpty {
                $0.append("ORDER BY", SQLList(self.orderBy))
            }
            if let limit = self.limit {
                $0.append("LIMIT", SQLLiteral.numeric("\(limit)"))
            }
            if let offset = self.offset {
                $0.append("OFFSET", SQLLiteral.numeric("\(offset)"))
            }
            $0.append(self.lockingClause)
        }
    }
}
