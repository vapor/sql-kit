/// An escaped identifier, i.e., `"name"`.
public protocol SQLIdentifier: SQLSerializable, ExpressibleByStringLiteral {
    /// Creates a new `SQLIdentifier`.
    static func identifier(_ string: String) -> Self
    
    /// String value.
    var string: String { get set }
}
