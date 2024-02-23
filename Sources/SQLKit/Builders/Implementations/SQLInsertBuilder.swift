/// Builds ``SQLInsert`` queries.
///
/// > Note: Although in the strictest sense, this builder could conform to ``SQLUnqualifiedColumnListBuilder``, doing
/// > so would be semantically inappropriate. the protocol documents its `columns()` methods as being additive, but
/// > ``SQLInsertBuilder``'s otherwise-identical public APIs overwrite the effects of any previous invocation. It
/// > would ideally be preferable to change ``SQLInsertBuilder``'s semantics in this regard, but this would be a
/// > significant breaking change in the API's behavior, and must therefore wait for a major version bump.
public final class SQLInsertBuilder: SQLQueryBuilder, SQLReturningBuilder/*, SQLUnqualifiedColumnListBuilder*/ {
    /// The ``SQLInsert`` query this builder builds.
    public var insert: SQLInsert
    
    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase
    
    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.insert
    }

    // See `SQLReturningBuilder.returning`.
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
    
    /// Use an `Encodable` value to generate a row to insert and add that row to the query.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// let earth = Planet(id: nil, name: "Earth", isInhabited: true)
    ///
    /// try await sqlDatabase.insert(into: "planets")
    ///     .model(earth, keyEncodingStrategy: .convertToSnakeCase)
    ///     .run()
    ///
    /// // Effectively the same as:
    /// try await sqlDatabase.insert(into: "planets")
    ///     .columns("id", "name", "is_inhabited")
    ///     .values(SQLBind(earth.id), SQLBind(earth.name), SQLBind(earth.isInhabited))
    ///     .run()
    /// ```
    ///
    /// > Note: The term "model" does _not_ refer to Fluent's `Model` type. Fluent models are not compatible with
    /// > this method or any of its variants.
    ///
    /// - Parameters:
    ///   - model: A value to insert. This can be any encodable type which represents an aggregate value.
    ///   - prefix: See ``SQLQueryEncoder/prefix``.
    ///   - keyEncodingStrategy: See ``SQLQueryEncoder/keyEncodingStrategy-swift.property``.
    ///   - nilEncodingStrategy: See ``SQLQueryEncoder/nilEncodingStrategy-swift.property`.
    @inlinable
    @discardableResult
    public func model(
        _ model: some Encodable,
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
    ///   - models: `Encodable` models to insert.
    ///   - prefix: An optional prefix to apply to the values' derived column names.
    ///   - keyEncodingStrategy: See ``SQLQueryEncoder/KeyEncodingStrategy-swift.enum``.
    ///   - nilEncodingStrategy: See ``SQLQueryEncoder/NilEncodingStrategy-swift.enum``.
    @discardableResult
    public func models(
        _ models: [some Encodable],
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
    
    /// Specify mutiple columns to be included in the list of columns for the query.
    ///
    /// Overwrites any previously specified column list.
    @inlinable
    @discardableResult
    public func columns(_ columns: String...) -> Self {
        self.columns(columns)
    }
    
    /// Specify mutiple columns to be included in the list of columns for the query.
    ///
    /// Overwrites any previously specified column list.
    @inlinable
    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.columns(columns.map(SQLIdentifier.init(_:)))
    }
    
    /// Specify mutiple columns to be included in the list of columns for the query.
    ///
    /// Overwrites any previously specified column list.
    @inlinable
    @discardableResult
    public func columns(_ columns: any SQLExpression...) -> Self {
        self.columns(columns)
    }
    
    /// Specify mutiple columns to be included in the list of columns for the query.
    ///
    /// Overwrites any previously specified column list.
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
    public func values(_ values: any Encodable & Sendable...) -> Self {
        self.values(values)
    }
    
    /// Add a set of values to be inserted as a single row.
    @inlinable
    @discardableResult
    public func values(_ values: [any Encodable & Sendable]) -> Self {
        self.values(values.map { SQLBind($0) })
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
    
    /// Specify a `SELECT` query to generate rows to insert.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// try await database.insert(into: "table")
    ///     .columns("id", "foo", "bar")
    ///     .select { $0
    ///         .column(SQLLiteral.default, as: "id")
    ///         .column("foo", table: "other")
    ///         .column("bar", table: "other")
    ///         .from("other")
    ///         .where(SQLColumn("created_at", table: "other"), .greaterThan, SQLBind(someDate))
    ///     }
    ///     .run()
    /// ```
    ///
    /// - Parameter closure: A closure which builds a `SELECT` subquery using the provided builder.
    @inlinable
    @discardableResult
    public func select(_ closure: (SQLSubqueryBuilder) throws -> SQLSubqueryBuilder) rethrows -> Self {
        let builder = SQLSubqueryBuilder()
        _ = try closure(builder)
        self.insert.valueQuery = builder.select
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
