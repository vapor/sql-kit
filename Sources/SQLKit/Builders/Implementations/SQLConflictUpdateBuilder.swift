/// A builder for specifying column updates and an optional predicate to be applied to
/// rows that caused unique key conflicts during an `INSERT`.
public final class SQLConflictUpdateBuilder: SQLColumnUpdateBuilder, SQLPredicateBuilder {
    /// See ``SQLColumnUpdateBuilder/values``.
    public var values: [any SQLExpression]
    
    /// See ``SQLPredicateBuilder/predicate``.
    public var predicate: (any SQLExpression)?
    
    /// Create a conflict update builder.
    @usableFromInline
    init() {
        self.values = []
        self.predicate = nil
    }

    /// Add an assignment of the column with the given name, using the value the column was
    /// given in the `INSERT` query's `VALUES` list. See ``SQLExcludedColumn``.
    @inlinable
    @discardableResult
    public func set(excludedValueOf columnName: String) -> Self {
        self.set(excludedValueOf: SQLColumn(columnName))
    }
    
    /// Add an assignment of the given column, using the value the column was given in the
    /// `INSERT` query's `VALUES` list. See ``SQLExcludedColumn``.
    @inlinable
    @discardableResult
    public func set(excludedValueOf column: any SQLExpression) -> Self {
        self.values.append(SQLColumnAssignment(settingExcludedValueFor: column))
        return self
    }
    
    /// Encodes the given ``Encodable`` value to a sequence of key-value pairs and adds an assignment
    /// for each pair which uses the values each column was given in the original `INSERT` query's
    /// `VALUES` list. See ``SQLExcludedColumn``.
    @inlinable
    @discardableResult
    public func set<E>(excludedContentOf model: E) throws -> Self where E: Encodable {
        try SQLQueryEncoder().encode(model).reduce(self) { $0.set(excludedValueOf: $1.0) }
    }
}
