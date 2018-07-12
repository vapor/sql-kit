/// `DEFAULT` literal.
///
/// Some SQL-dialects prefer `NULL` instead of `DEFAULT`, so this must be protocolized.
public protocol SQLDefaultLiteral: SQLSerializable {
    /// Default.
    static var `default`: Self { get }
}
