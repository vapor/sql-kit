/// An expression appearing on the right side of a column assignment which, when the assignment list
/// is part of an upsert's update acion, refers to the value which was originally to be inserted for
/// the given column.
///
/// - Note: If the serializer's dialect does not support upserts, this expression silently evaluates
///   to nothing at all.
///
/// - Warning: At the time of this writing, MySQL 8.0's recommended "table alias" syntax for
///   excluded columns is not implemented, due to there currently being no way for a ``SQLDialect``
///   to vary its contents based on the database server version (for that matter, we don't even
///   have support for retrieving the version from `MySQLNIO`). For now, the deprecared `VALUES()`
///   function is used unconditionally, which will throw warnings starting from MySQL 8.0.20.
///   If this affects your usage, use a raw query or manually construct the necessary expressions
///   to specify and use the alias for now.
public struct SQLExcludedColumn: SQLExpression {
    public var name: any SQLExpression
    
    @inlinable
    public init(_ name: String) {
        self.init(SQLColumn(name))
    }
    
    @inlinable
    public init(_ name: any SQLExpression) {
        self.name = name
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.upsertSyntax {
            case .standard:
                /// The `excluded` table name is a context-specific keyword, _not_ an identifier.
                /// Accordingly, we must add the separating `.` between the keyword and the column
                /// name manually, since `SQLColumn` would do the wrong thing here.
                serializer.write("EXCLUDED.")
                self.name.serialize(to: &serializer)
            case .mysqlLike:
                SQLFunction("VALUES", args: self.name).serialize(to: &serializer)
            case .unsupported:
                break // A warning logged from here would either be annoyingly noisy or never appear at all.
        }
    }
}

