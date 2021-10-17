/// Builds `SQLInsert` queries.
///
///     db.insert(into: "planets"")
///         .value(earth).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLInsertBuilder: SQLQueryBuilder, SQLReturningBuilder {
    /// `Insert` query being built.
    public var insert: SQLInsert
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.insert
    }

    public var returning: SQLReturning? {
        get { return self.insert.returning }
        set { self.insert.returning = newValue }
    }
    
    /// Creates a new `SQLInsertBuilder`.
    public init(_ insert: SQLInsert, on database: SQLDatabase) {
        self.insert = insert
        self.database = database
    }
    
    /// Adds a single encodable value to be inserted. Equivalent to calling `values(_:)`
    /// with single-element array.
    ///
    ///     db.insert(into: Planet.self)
    ///         .value(earth).run()
    ///
    /// - parameters:
    ///     - value: `Encodable` value to insert.
    /// - returns: Self for chaining.
    @discardableResult
    public func model<E>(_ model: E, prefix: String? = nil, keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys, nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default) throws -> Self
        where E: Encodable {
        return try models([model], prefix: prefix, keyEncodingStrategy: keyEncodingStrategy, nilEncodingStrategy: nilEncodingStrategy)
    }
    
    @discardableResult
    public func models<E>(_ models: [E], prefix: String? = nil, keyEncodingStrategy: SQLQueryEncoder.KeyEncodingStrategy = .useDefaultKeys, nilEncodingStrategy: SQLQueryEncoder.NilEncodingStrategy = .default) throws -> Self where E: Encodable {
        var encoder = SQLQueryEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.nilEncodingStrategy = nilEncodingStrategy
        encoder.prefix = prefix

        for model in models {
            let row = try encoder.encode(model)
            if self.insert.columns.isEmpty {
                self.insert.columns += row.map { $0.0 }.map { SQLColumn($0, table: nil) }
            } else {
                assert(
                    self.insert.columns.count == row.count,
                    "Column count (\(self.insert.columns.count)) did not equal value count (\(row.count)): \(model)."
                )
            }
            self.insert.values.append(.init(row.map { $0.1 }))
        }

        return self
    }
    
    @discardableResult
    public func columns(_ columns: String...) -> Self {
        self.insert.columns = columns.map(SQLIdentifier.init(_:))
        return self
    }
    
    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.insert.columns = columns.map(SQLIdentifier.init(_:))
        return self
    }
    
    @discardableResult
    public func columns(_ columns: SQLExpression...) -> Self {
        self.insert.columns = columns
        return self
    }
    
    @discardableResult
    public func columns(_ columns: [SQLExpression]) -> Self {
        self.insert.columns = columns
        return self
    }
    
    @discardableResult
    public func values(_ values: Encodable...) -> Self {
        let row: [SQLExpression] = values.map(SQLBind.init)
        self.insert.values.append(row)
        return self
    }
    
    @discardableResult
    public func values(_ values: [Encodable]) -> Self {
        let row: [SQLExpression] = values.map(SQLBind.init)
        self.insert.values.append(row)
        return self
    }
    
    @discardableResult
    public func values(_ values: SQLExpression...) -> Self {
        self.insert.values.append(values)
        return self
    }
    
    @discardableResult
    public func values(_ values: [SQLExpression]) -> Self {
        self.insert.values.append(values)
        return self
    }

    @discardableResult
    public func ignoringConflicts(with targetColumns: [String] = []) -> Self {
        self.insert.conflictStrategy = .init(targets: targetColumns, action: .noAction)
        return self
    }

    @discardableResult
    public func ignoringConflicts(with targetColumns: [SQLExpression] = []) -> Self {
        self.insert.conflictStrategy = .init(targets: targetColumns, action: .noAction)
        return self
    }

    @discardableResult
    public func onConflict(
        with targetColumns: [String] = [],
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        let conflictBuilder = SQLConflictUpdateBuilder()
        _ = try updatePredicate(conflictBuilder)
        
        self.insert.conflictStrategy = .init(targets: targetColumns, action: .update(assignments: conflictBuilder.values, predicate: conflictBuilder.predicate))
        return self
    }
    
    @discardableResult
    public func onConflict(
        with targetColumns: [SQLExpression] = [],
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        let conflictBuilder = SQLConflictUpdateBuilder()
        _ = try updatePredicate(conflictBuilder)
        
        self.insert.conflictStrategy = .init(targets: targetColumns, action: .update(assignments: conflictBuilder.values, predicate: conflictBuilder.predicate))
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLInsertBuilder`.
    ///
    ///     db.insert(into: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to insert into.
    /// - returns: Newly created `SQLInsertBuilder`.
    public func insert(into table: String) -> SQLInsertBuilder {
        return self.insert(into: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLInsertBuilder`.
    ///
    ///     db.insert(into: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to insert into.
    /// - returns: Newly created `SQLInsertBuilder`.
    public func insert(into table: SQLExpression) -> SQLInsertBuilder {
        return .init(.init(table: table), on: self)
    }
}
