extension SQLSerializer {
    public mutating func statement(_ closure: (inout SQLStatement) -> ()) {
        var sql = SQLStatement(parts: [], database: self.database)
        closure(&sql)
        sql.serialize(to: &self)
    }
}

/// A helper type for building complete SQL statements up from fragments.
/// See also `SQLSerializer.statement(_:)`.
public struct SQLStatement: SQLExpression {
    public var parts: [SQLExpression]
    let database: SQLDatabase

    /// Convenience accessor for the database's `SQLDialect`.
    ///
    /// - Note: Statement closures can't access the serializer directly due to exclusive access rules.
    public var dialect: SQLDialect {
        self.database.dialect
    }

    /// Add raw text to the output.
    public mutating func append(_ raw: String) {
        self.append(SQLRaw(raw))
    }
    
    /// Add raw text followed by an `SQLExpression` to tbe output.
    ///
    /// - Note: "Text + expr" pairs appear quite often when building statments.
    public mutating func append(_ raw: String, _ part: SQLExpression) {
        self.append(raw)
        self.append(part)
    }

    /// Add an `SQLExpression` of any kind to the output.
    public mutating func append(_ part: SQLExpression) {
        self.parts.append(part)
    }
    
    /// Add an ``SQLExpression`` of any kind to the output, but only if it isn't `nil`.
    public mutating func append(_ maybePart: SQLExpression?) {
        maybePart.map { self.append($0) }
    }

    // See `SQLSerializer.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        for i in self.parts.indices {
            if i > self.parts.startIndex {
                serializer.write(" ")
            }
            self.parts[i].serialize(to: &serializer)
        }
    }
}
