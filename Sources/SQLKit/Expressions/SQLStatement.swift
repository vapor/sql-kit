extension SQLSerializer {
    @inlinable
    public mutating func statement(_ closure: (inout SQLStatement) -> ()) {
        var sql = SQLStatement(database: self.database)
        closure(&sql)
        sql.serialize(to: &self)
    }
}

/// A helper type for building complete SQL statements up from fragments.
/// See also `SQLSerializer.statement(_:)`.
public struct SQLStatement: SQLExpression {
    /// The individual expressions collected by the statement, in order.
    public var parts: [any SQLExpression] = []
    
    @usableFromInline
    let database: any SQLDatabase

    @usableFromInline
    init(database: any SQLDatabase) {
        self.database = database
    }

    /// Convenience accessor for the database's ``SQLDialect``.
    ///
    /// > Note: Exclusive access checking prevents statement closures from accessing the serializer directly.
    @inlinable
    public var dialect: any SQLDialect {
        self.database.dialect
    }

    /// Add raw text to the output.
    @inlinable
    public mutating func append(_ raw: String) {
        self.append(SQLRaw(raw))
    }
    
    /// Add raw text followed by an ``SQLExpression`` to tbe output.
    ///
    /// > Note: "Text + expr" pairs appear quite often when building statments.
    @inlinable
    public mutating func append(_ raw: String, _ part: any SQLExpression) {
        self.append(raw)
        self.append(part)
    }

    /// Add an ``SQLExpression`` of any kind to the output.
    @inlinable
    public mutating func append(_ part: any SQLExpression) {
        self.parts.append(part)
    }
    
    /// Add an optional ``SQLExpression`` of any kind to the output, ignoring `nil` values.
    @inlinable
    public mutating func append(_ maybePart: (any SQLExpression)?) {
        maybePart.map { self.append($0) }
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        for i in self.parts.indices {
            if i > self.parts.startIndex {
                serializer.write(" ")
            }
            self.parts[i].serialize(to: &serializer)
        }
    }
}
