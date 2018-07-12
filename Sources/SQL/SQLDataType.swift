/// SQL data type protocol, i.e., `INTEGER`, `TEXT`, etc.
public protocol SQLDataType: SQLSerializable {
    /// Creates a new `SQLDataType` appropriate for the supplied Swift type.
    ///
    /// If no appropriate data type is known, `nil` is returned.
    static func dataType(appropriateFor: Any.Type) -> Self?
}
