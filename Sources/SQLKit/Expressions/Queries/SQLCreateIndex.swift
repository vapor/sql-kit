/// An expression representing a `CREATE INDEX` query. Used to add indexes over columns to an existing table.
///
/// ```sql
/// CREATE INDEX "name" ON "table" ("column1", "column2") WHERE "column1"=$0;
/// ```
///
/// Not all dialects support index predicates, nor does this expression attempt to support all of the numerous
/// additional indexing options available with different drivers.
///
/// > Note: Because support for an `IF NOT EXISTS` clause on `CREATE IDNEX` queries varies in unusual ways between
/// > dialects, it is not currently supported by this expression.
///
/// See ``SQLCreateIndexBuilder``.
public struct SQLCreateIndex: SQLExpression {
    /// The name of the index.
    ///
    /// In some dialects, an index's name may be required to be unique within an entire database or schema, not just
    /// within the same table. This name is also used as the name of the `UNIQUE` constraint which is added to the
    /// table, and thus must also follow the restrictions on constraint naming.
    public var name: any SQLExpression
    
    /// The table containing the data to be indexed.
    ///
    /// This value is optional only due to legacy API design; it is required by all dialects and serialization will
    /// produce invalid syntax if it is `nil`.
    public var table: (any SQLExpression)?
    
    /// If not `nil`, must be set to ``SQLColumnConstraintAlgorithm/unique``.
    ///
    /// This property is another legacy API design flaw, as well as reflecting the overlap in most dialects between
    /// table-level `UNIQUE` constraints and unique indexes, both of which imply each other but are treated as
    /// more or less distinct entities at the syntactic level.
    public var modifier: (any SQLExpression)?
    
    /// The list of columns covered by the index.
    public var columns: [any SQLExpression]
    
    /// If not `nil`, a predicate identifying which rows of the table are included in the index.
    ///
    /// Not all dialects support partial indexes. There is currently no check for this; users must ensure that a
    /// predicate is not specified when not supported.
    public var predicate: (any SQLExpression)?
    
    /// Create a index creation query.
    ///
    /// - Parameter name: The name to assign to the index/constraint.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.table = nil
        self.modifier = nil
        self.columns = []
        self.predicate = nil
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("CREATE", self.modifier, "INDEX")
            $0.append("ON", self.table)
            $0.append(SQLGroupExpression(self.columns))
            if let predicate = self.predicate {
                $0.append("WHERE", predicate)
            }
        }
    }
}
