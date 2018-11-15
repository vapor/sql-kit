/// Literal expression value, i.e., `DEFAULT`, `FALSE`, `42`, etc.
public protocol SQLLiteral: SQLSerializable, ExpressibleByStringLiteral {
    /// Creates a new `SQLLiteral` from a string.
    static func string(_ string: String) -> Self
    
    /// Creates a new `SQLLiteral` from a numeric string (no quotes).
    static func numeric(_ string: String) -> Self
    
    /// Creates a new null `SQLLiteral`, i.e., `NULL`.
    static var null: Self { get }
    
    /// Creates a new default `SQLLiteral` literal, i.e., `DEFAULT` or sometimes `NULL`.
    static var `default`: Self { get }
    
    /// Creates a new boolean `SQLLiteral`, i.e., `FALSE` or sometimes `0`.
    static func boolean(_ bool: Bool) -> Self
    
    /// If `true`, this `SQLLiteral` represents `NULL`.
    var isNull: Bool { get }
}
