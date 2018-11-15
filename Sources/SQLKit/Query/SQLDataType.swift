/// SQL data type protocol, i.e., `INTEGER`, `TEXT`, etc.
public protocol SQLDataType: SQLSerializable {
    static var int: Self { get }
    static var string: Self { get }
    static var double: Self { get }
    static var date: Self { get }
    static func custom(_ name: String) -> Self
    
    /// Creates a new `SQLDataType` appropriate for the supplied Swift type.
    ///
    /// If no appropriate data type is known, `nil` is returned.
    static func dataType(appropriateFor: Any.Type) -> Self?
}
