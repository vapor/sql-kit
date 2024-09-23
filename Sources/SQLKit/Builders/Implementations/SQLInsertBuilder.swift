/// Builds ``SQLInsert`` queries.
///
/// > Note: Although in the strictest sense, this builder could conform to ``SQLUnqualifiedColumnListBuilder``, doing
/// > so would be semantically inappropriate. The protocol documents its `columns()` methods as being additive, but
/// > ``SQLInsertBuilder``'s otherwise-identical public APIs overwrite the effects of any previous invocation. It
/// > would ideally be preferable to change ``SQLInsertBuilder``'s semantics in this regard, but this would be a
/// > significant breaking change in the API's behavior, and must therefore wait for a major version bump.
public final class SQLInsertBuilder: SQLQueryBuilder, SQLReturningBuilder/*, SQLUnqualifiedColumnListBuilder*/, SQLCommonTableExpressionBuilder {
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
    
    // See `SQLCommonTableExpressionBuilder.tableExpressionGroup`.
    @inlinable
    public var tableExpressionGroup: SQLCommonTableExpressionGroup? {
        get { self.insert.tableExpressionGroup }
        set { self.insert.tableExpressionGroup = newValue }
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
    ///   - userInfo: See ``SQLQueryEncoder/userInfo``.
    @inlinable
    @discardableResult
    public func model(
        _ model: some Encodable,
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) throws -> Self {
        try self.models(
            [model],
            prefix: prefix,
            keyEncodingStrategy: keyEncodingStrategy,
            nilEncodingStrategy: nilEncodingStrategy,
            userInfo: userInfo
        )
    }

    /// Use an `Encodable` value to generate a row to insert and add that row to the query.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// let earth = Planet(id: nil, name: "Earth", isInhabited: true)
    /// let encoder = SQLQueryEncoder(nilEncodingStrategy: .asNil)
    ///
    /// try await sqlDatabase.insert(into: "planets")
    ///     .model(earth, with: encoder)
    ///     .run()
    ///
    /// // Effectively the same as:
    /// try await sqlDatabase.insert(into: "planets")
    ///     .columns("id", "name", "isInhabited")
    ///     .values(SQLLiteral.null, SQLBind(earth.name), SQLBind(earth.isInhabited))
    ///     .run()
    /// ```
    ///
    /// > Note: The term "model" does _not_ refer to Fluent's `Model` type. Fluent models are not compatible with
    /// > this method or any of its variants.
    ///
    /// - Parameters:
    ///   - model: A value to insert. This can be any encodable type which represents an aggregate value.
    ///   - encoder: A preconfigured ``SQLQueryEncoder`` to use for encoding.
    @inlinable
    @discardableResult
    public func model(
        _ model: some Encodable,
        with encoder: SQLQueryEncoder
    ) throws -> Self {
        try self.models([model], with: encoder)
    }

    /// Use an array of `Encodable` values to generate rows to insert and add those rows to the query.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// let earth = Planet(id: nil, name: "Earth", isInhabited: true)
    /// let mars = Planet(id: nil, name: "Mars", isInhabited: false)
    ///
    /// try await sqlDatabase.insert(into: "planets")
    ///     .models([earth, mars], keyEncodingStrategy: .convertToSnakeCase)
    ///     .run()
    ///
    /// // Effectively the same as:
    /// try await sqlDatabase.insert(into: "planets")
    ///     .columns("id", "name", "is_inhabited")
    ///     .values(SQLBind(earth.id), SQLBind(earth.name), SQLBind(earth.isInhabited))
    ///     .values(SQLBind(mars.id), SQLBind(mars.name), SQLBind(mars.isInhabited))
    ///     .run()
    /// ```
    ///
    /// > Note: The term "model" does _not_ refer to Fluent's `Model` type. Fluent models are not compatible with
    /// > this method or any of its variants.
    ///
    /// - Parameters:
    ///   - models: Array of values of a given type to insert. The given type may be any encodable type which
    ///     represents an aggregate value.
    ///   - prefix: See ``SQLQueryEncoder/prefix``.
    ///   - keyEncodingStrategy: See ``SQLQueryEncoder/keyEncodingStrategy-swift.property``.
    ///   - nilEncodingStrategy: See ``SQLQueryEncoder/nilEncodingStrategy-swift.property`.
    ///   - userInfo: See ``SQLQueryEncoder/userInfo``.
    @inlinable
    @discardableResult
    public func models(
        _ models: [some Encodable],
        prefix: String? = nil,
        keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) throws -> Self {
        try self.models(models, with: .init(prefix: prefix, keyEncodingStrategy: keyEncodingStrategy, nilEncodingStrategy: nilEncodingStrategy, userInfo: userInfo))
    }
    
    /// Use an array of `Encodable` values to generate rows to insert and add those rows to the query.
    ///
    /// Example usage:
    /// ```swift
    /// let earth = Planet(id: nil, name: "Earth", isInhabited: true)
    /// let mars = Planet(id: nil, name: "Mars", isInhabited: false)
    /// let encoder = SQLQueryEncoder(nilEncodingStrategy: .asNil)
    ///
    /// try await sqlDatabase.insert(into: "planets")
    ///     .models([earth, mars], with: encoder)
    ///     .run()
    ///
    /// // Effectively the same as:
    /// try await sqlDatabase.insert(into: "planets")
    ///     .columns("id", "name", "isInhabited")
    ///     .values(SQLLiteral.null, SQLBind(earth.name), SQLBind(earth.isInhabited))
    ///     .values(SQLLiteral.null, SQLBind(mars.name), SQLBind(mars.isInhabited))
    ///     .run()
    /// ```
    ///
    /// > Note: The term "model" does _not_ refer to Fluent's `Model` type. Fluent models are not compatible with
    /// > this method or any of its variants.
    ///
    /// - Parameters:
    ///   - models: Array of values of a given type to insert. The given type may be any encodable type which
    ///     represents an aggregate value.
    ///   - encodder: A preconfigured ``SQLQueryEncoder`` to use for encoding.
    @discardableResult
    public func models(
        _ models: [some Encodable],
        with encoder: SQLQueryEncoder
    ) throws -> Self {
        var validColumns: [String] = []
        
        for model in models {
            let row = try encoder.encode(model)
            if validColumns.isEmpty {
                validColumns = row.map(\.0)
                self.columns(validColumns)
            } else {
                /// This is not the most ideal way to handle the "inconsistent NULL-ness" problem, but the established
                /// public API of ``SQLQueryEncoder`` makes doing something nicer sufficiently complicated as to be
                /// impractical; this will be rectified properly when the major version of SQLKit is next bumped.
                guard validColumns == row.map(\.0) else {
                    throw EncodingError.invalidValue(model, .init(codingPath: [], debugDescription: """
                        One or more input models does not encode to the same set of columns. \
                        This is usually the result of only some of the inputs having `nil` values for optional properties. \
                        Try using `NilEncodingStrategy.asNil` to avoid this error.
                        """
                    ))
                }
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

    /// Add multiple sequences of values each inserted as a separate row.
    @inlinable
    @discardableResult
    public func rows<S1, S2>(_ valueSets: S1) -> Self
        where S1: Sequence, S2: Sequence,
              S1.Element == S2, S2.Element == any SQLExpression
    {
        valueSets.reduce(self) { $0.values(Array($1)) }
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
