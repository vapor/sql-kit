/// A parameterizied value bound to the SQL query.
public protocol SQLBind: SQLSerializable {
    /// Creates a `SQLBind` from an `Encodable` value.
    static func encodable<E>(_ value: E) -> Self
        where E: Encodable
}

// MARK: Generic

/// Generic implementation of `SQLBind`. Uses `"?"` as a placeholder.
public struct GenericSQLBind: SQLBind {
    /// See `SQLBind`.
    public static func encodable<E>(_ value: E) -> GenericSQLBind
        where E: Encodable
    {
        return self.init(value: value)
    }
    
    /// Stored encodable value.
    public var value: Encodable
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        binds.append(value)
        return "?"
    }
}
