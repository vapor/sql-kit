/// Encapsulates the most basic operations for serializing ``SQLExpression``s into a raw SQL string and a
/// (potentially empty) sequence of bound parameter values.
public struct SQLSerializer: Sendable {
    /// The generated raw SQL text.
    public var sql: String
    
    /// The list of bound parameter values (if any).
    public var binds: [any Encodable & Sendable]
    
    /// The database for this serializer.
    public let database: any SQLDatabase
    
    /// Convenience accessor for the ``SQLDatabase/dialect`` of ``SQLSerializer/database``.
    @inlinable
    public var dialect: any SQLDialect {
        self.database.dialect
    }
    
    /// Create a new ``SQLSerializer`` for a given ``SQLDatabase``.
    ///
    /// - Parameter database: The database which will run the serialized query.
    @inlinable
    public init(database: any SQLDatabase) {
        self.sql = ""
        self.binds = []
        self.database = database
    }
    
    /// Add a bound parameter value to the serializer.
    ///
    /// - Parameter encodable: The value to bind.
    @inlinable
    public mutating func write(bind encodable: any Encodable & Sendable) {
        self.binds.append(encodable)
        self.dialect.bindPlaceholder(at: self.binds.count)
            .serialize(to: &self)
    }
    
    /// Append raw SQL to the serializer.
    ///
    /// - Parameter sql: The text to append.
    @inlinable
    public mutating func write(_ sql: String) {
        self.sql += sql
    }
}
