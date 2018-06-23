public protocol SQLBind: SQLSerializable {
    static func encodable<E>(_ value: E) -> Self
        where E: Encodable
    
    var value: Encodable { get }
}

// MARK: Generic

public struct GenericSQLBind: SQLBind {
    /// See `SQLBind`.
    public static func encodable<E>(_ value: E) -> GenericSQLBind
        where E: Encodable
    {
        return self.init(value: value)
    }
    
    public var value: Encodable
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        binds.append(value)
        return "?"
    }
}
