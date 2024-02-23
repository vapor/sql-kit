/// A builder for specifying column updates and an optional predicate to be applied to
/// rows that caused unique key conflicts during an `INSERT`.
public final class SQLConflictUpdateBuilder: SQLColumnUpdateBuilder, SQLPredicateBuilder {
    // See `SQLColumnUpdateBuilder.values`.
    public var values: [any SQLExpression]
    
    // See `SQLPredicateBuilder.predicate`.
    public var predicate: (any SQLExpression)?
    
    /// Create a conflict update builder.
    @usableFromInline
    init() {
        self.values = []
        self.predicate = nil
    }

    /// Add an assignment of the column with the given name, using the value the column was
    /// given in the `INSERT` query's `VALUES` list.
    ///
    /// See ``SQLExcludedColumn`` for additional details.
    @inlinable
    @discardableResult
    public func set(excludedValueOf columnName: String) -> Self {
        self.set(excludedValueOf: SQLColumn(columnName))
    }
    
    /// Add an assignment of the given column, using the value the column was given in the
    /// `INSERT` query's `VALUES` list.
    ///
    /// See ``SQLExcludedColumn`` for additional details.
    @inlinable
    @discardableResult
    public func set(excludedValueOf column: any SQLExpression) -> Self {
        self.values.append(SQLColumnAssignment(settingExcludedValueFor: column))
        return self
    }
    
    /// Encodes the given `Encodable` value to a sequence of key-value pairs and adds an assignment
    /// for each pair which uses the values each column was given in the original `INSERT` query's
    /// `VALUES` list.
    ///
    /// See ``SQLExcludedColumn`` and ``SQLQueryEncoder`` for additional details.
    ///
    /// > Important: The actual values stored in the provided `model` _are not used_ by this method.
    /// > The model is encoded, then the resulting values are discarded and the list of column names
    /// > is used to repeatedly invoke ``set(excludedValueOf:)-zmis``. This is potentially very
    /// > inefficient; a future version of the API will offer the ability to efficiently set the
    /// > excluded values for all input columns in one operation.
    @inlinable
    @discardableResult
    public func set(
        excludedContentOf model: some Encodable & Sendable,
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default
    ) throws -> Self {
        try self.set(
            excludedContentOf: model,
            with: .init(prefix: prefix, keyEncodingStrategy: keyEncodingStrategy, nilEncodingStrategy: nilEncodingStrategy)
        )
    }

    /// Encodes the given `Encodable` value to a sequence of key-value pairs and adds an assignment
    /// for each pair which uses the values each column was given in the original `INSERT` query's
    /// `VALUES` list. See ``SQLExcludedColumn`` and ``SQLQueryEncoder``.
    ///
    /// > Important: The actual values stored in the provided `model` _are not used_ by this method.
    /// > The model is encoded, then the resulting values are discarded and the list of column names
    /// > is used to repeatedly invoke ``set(excludedValueOf:)-zmis``. This is potentially very
    /// > inefficient; a future version of the API will offer the ability to efficiently set the
    /// > excluded values for all input columns in one operation.
    @inlinable
    @discardableResult
    public func set(
        excludedContentOf model: some Encodable & Sendable,
        with encoder: SQLQueryEncoder
    ) throws -> Self {
        try encoder.encode(model).reduce(self) { $0.set(excludedValueOf: $1.0) }
    }
}
