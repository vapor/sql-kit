/// Boolean literal, i.e., `FALSE`, `TRUE`.
///
/// Some SQL dialects prefer `0` and `1`.
public protocol SQLBoolLiteral: SQLSerializable {
    /// Boolean `true` / `1` literal.
    static var `true`: Self { get }
    
    /// Boolean `false` / `0` literal.
    static var `false`: Self { get }
}
