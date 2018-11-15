#warning("re-add reflectable support?")

/// A type corresponding to a table / view in a SQL database.
public protocol SQLTable: AnySQLTable /*, Reflectable*/ { }

extension SQLTable {
    public static func column<C>(_ name: String) -> C
        where C: SQLColumnIdentifier
    {
        return .column(self.table(), .identifier(name))
    }
    
    public static func table<T>() -> T
        where T: SQLTableIdentifier
    {
        return .table(.identifier(self.sqlTableIdentifierString))
    }
}

/// Type-erased `SQLTable`.
public protocol AnySQLTable: Codable /*, AnyReflectable */ {
    /// Name of the SQL table this type corresponds to.
    /// Defaults to the name of the type.
    static var sqlTableIdentifierString: String { get }
}

extension AnySQLTable {
    /// See `AnySQLTable`.
    public static var sqlTableIdentifierString: String {
        return "\(Self.self)"
    }
}
