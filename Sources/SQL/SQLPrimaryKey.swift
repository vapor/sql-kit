public protocol SQLPrimaryKey: SQLSerializable {
    static func primaryKey() -> Self
}

// MARK: Generic

public struct GenericSQLPrimaryKey: SQLPrimaryKey {
    /// See `SQLPrimaryKey`.
    public static func primaryKey() -> GenericSQLPrimaryKey {
        return .init()
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return ""
    }
}
