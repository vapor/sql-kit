/// Builds ``SQLInsert`` queries.
public final class SQLInsertBuilder: SQLQueryBuilder, SQLReturningBuilder {
    /// ``SQLInsert`` query being built.
    public var insert: SQLInsert
    
    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase
    
    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.insert
    }

    /// See ``SQLReturningBuilder/returning``.
    @inlinable
    public var returning: SQLReturning? {
        get { self.insert.returning }
        set { self.insert.returning = newValue }
    }
    
    /// Creates a new `SQLInsertBuilder`.
    @inlinable
    public init(_ insert: SQLInsert, on database: any SQLDatabase) {
        self.insert = insert
        self.database = database
    }
    
    /// Adds a single encodable value to be inserted.
    ///
    ///     db.insert(into: Planet.self).model(earth).run()
    ///
    /// - Note: The term "model" here does _not_ refer to Fluent's `Model` type.
    ///
    /// - Parameters:
    ///   - model: ``Encodable`` model to insert. This can be any encodable type.
    ///   - prefix: An optional prefix to apply to the value's derived column names.
    ///   - keyEncodingStrategy: See ``SQLQueryEncoder/KeyEncodingStrategy-swift.enum``.
    ///   - nilEncodingStrategy: See ``SQLQueryEncoder/NilEncodingStrategy-swift.enum``.
    @inlinable
    @discardableResult
    public func model<E: Encodable>(
        _ model: E, // TODO: When we start requiring Swift 5.7+, use `some Encodable` here.
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default
    ) throws -> Self {
        try models([model], prefix: prefix, keyEncodingStrategy: keyEncodingStrategy, nilEncodingStrategy: nilEncodingStrategy)
    }
    
    /// Adds an array of encodable values to be inserted.
    ///
    ///     db.insert(into: Planet.self).models([mercury, venus, earth, mars]).run()
    ///
    /// - Note: The term "model" here does _not_ refer to Fluent's `Model` type.
    ///
    /// - Parameters:
    ///   - models: ``Encodable`` models to insert.
    ///   - prefix: An optional prefix to apply to the values' derived column names.
    ///   - keyEncodingStrategy: See ``SQLQueryEncoder/KeyEncodingStrategy-swift.enum``.
    ///   - nilEncodingStrategy: See ``SQLQueryEncoder/NilEncodingStrategy-swift.enum``.
    @discardableResult
    public func models<E: Encodable>(
        _ models: [E], // TODO: When we start requiring Swift 5.7+, use `some Encodable` here.
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default
    ) throws -> Self {
        let encoder = SQLQueryEncoder(prefix: prefix, keyEncodingStrategy: keyEncodingStrategy, nilEncodingStrategy: nilEncodingStrategy)

        for model in models {
            let row = try encoder.encode(model)
            if self.insert.columns.isEmpty {
                self.columns(row.map(\.0))
            } else {
                assert(self.insert.columns.count == row.count, "Wrong number of columns in model (wanted \(self.insert.columns.count), got \(row.count)): \(model)")
            }
            self.values(row.map(\.1))
        }
        return self
    }
    
    /// Specify the set of columns that appear in the list(s) of values.
    ///
    /// Overwrites the existing set of columns, if any.
    @inlinable
    @discardableResult
    public func columns(_ columns: String...) -> Self {
        self.columns(columns)
    }
    
    /// Specify the set of columns that appear in the list(s) of values.
    ///
    /// Overwrites the existing set of columns, if any.
    @inlinable
    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.columns(columns.map(SQLIdentifier.init(_:)))
    }
    
    /// Specify the set of columns that appear in the list(s) of values.
    ///
    /// Overwrites the existing set of columns, if any.
    @inlinable
    @discardableResult
    public func columns(_ columns: any SQLExpression...) -> Self {
        self.columns(columns)
    }
    
    /// Specify the set of columns that appear in the list(s) of values.
    ///
    /// Overwrites the existing set of columns, if any.
    @inlinable
    @discardableResult
    public func columns(_ columns: [any SQLExpression]) -> Self {
        self.insert.columns = columns
        return self
    }
    
    /// Add a set of values to be inserted as a single row.
    @inlinable
    @discardableResult
    @_disfavoredOverload
    public func values(_ values: any Encodable...) -> Self { // TODO: When we require Swift 5.7+, use `some Encodable` here.
        self.values(values)
    }
    
    /// Add a set of values to be inserted as a single row.
    @inlinable
    @discardableResult
    public func values(_ values: [any Encodable]) -> Self { // TODO: When we require Swift 5.7+, use `some Encodable` here.
        self.values(values.map(SQLBind.init(_:)))
    }
    
    /// Add a set of values to be inserted as a single row.
    @inlinable
    @discardableResult
    public func values(_ values: any SQLExpression...) -> Self {
        self.values(values)
    }
    
    /// Add a set of values to be inserted as a single row.
    @inlinable
    @discardableResult
    public func values(_ values: [any SQLExpression]) -> Self {
        self.insert.values.append(values)
        return self
    }

    /// Specify that constraint violations for the key over the given column should cause the conflicting
    /// row(s) to be ignored.
    @inlinable
    @discardableResult
    public func ignoringConflicts(with targetColumn: String) -> Self {
        self.ignoringConflicts(with: [targetColumn])
    }

    /// Specify that constraint violations for the key over the given columns should cause the conflicting
    /// row(s) to be ignored.
    @inlinable
    @discardableResult
    public func ignoringConflicts(with targetColumns: [String] = []) -> Self {
        self.ignoringConflicts(with: targetColumns.map(SQLIdentifier.init(_:)))
    }

    /// Specify that constraint violations for the key over the given columns should cause the conflicting
    /// row(s) to be ignored.
    @inlinable
    @discardableResult
    public func ignoringConflicts(with targetColumns: [any SQLExpression]) -> Self {
        self.insert.conflictStrategy = .init(targets: targetColumns, action: .noAction)
        return self
    }

    /// Specify that constraint violations for the key over the given column should cause the conflicting
    /// row(s) to be updated as specified instead. See ``SQLConflictUpdateBuilder``.
    @inlinable
    @discardableResult
    public func onConflict(
        with targetColumn: String,
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        try self.onConflict(with: [targetColumn], do: updatePredicate)
    }

    /// Specify that constraint violations for the key over the given columns should cause the conflicting
    /// row(s) to be updated as specified instead. See ``SQLConflictUpdateBuilder``.
    @inlinable
    @discardableResult
    public func onConflict(
        with targetColumns: [String] = [],
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        try self.onConflict(with: targetColumns.map(SQLIdentifier.init(_:)), do: updatePredicate)
    }
    
    /// Specify that constraint violations for the key over the given column should cause the conflicting
    /// row(s) to be updated as specified instead. See ``SQLConflictUpdateBuilder``.
    @inlinable
    @discardableResult
    public func onConflict(
        with targetColumns: [any SQLExpression],
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        let conflictBuilder = SQLConflictUpdateBuilder()
        _ = try updatePredicate(conflictBuilder)
        self.insert.conflictStrategy = .init(
            targets: targetColumns,
            action: .update(assignments: conflictBuilder.values, predicate: conflictBuilder.predicate)
        )
        return self
    }
}

extension SQLDatabase {
    /// Create a new ``SQLInsertBuilder``.
    @inlinable
    public func insert(into table: String) -> SQLInsertBuilder {
        self.insert(into: SQLIdentifier(table))
    }
    
    /// Create a new ``SQLInsertBuilder``.
    @inlinable
    public func insert(into table: any SQLExpression) -> SQLInsertBuilder {
        .init(.init(table: table), on: self)
    }
}
